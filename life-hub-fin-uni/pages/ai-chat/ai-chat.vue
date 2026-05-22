<template>
	<view class="ai-chat-page">
		<!-- 消息列表 -->
		<scroll-view
			class="messages"
			scroll-y
			:scroll-top="scrollTop"
			:scroll-with-animation="true"
		>
			<view class="empty" v-if="messages.length === 0">
				<view class="empty-icon">💰</view>
				<text class="empty-title">财务 AI 助手</text>
				<text class="empty-desc">问我任何理财、记账、预算的问题</text>
				<view class="suggestions">
					<view
						class="suggestion"
						v-for="(s, i) in suggestions"
						:key="i"
						@click="sendMessage(s)"
					>
						<text>{{ s }}</text>
					</view>
				</view>
			</view>

			<view
				v-for="(msg, idx) in messages"
				:key="idx"
				:class="['msg-row', msg.role === 'user' ? 'user' : 'assistant']"
			>
				<view class="bubble">
					<view v-if="msg.streaming && !msg.content" class="thinking">
						<view class="dot"></view>
						<view class="dot"></view>
						<view class="dot"></view>
					</view>
					<text v-else class="content" :selectable="true">{{ msg.content }}{{ msg.streaming ? '▎' : '' }}</text>
				</view>
			</view>
		</scroll-view>

		<!-- 输入区 -->
		<view class="input-area">
			<input
				class="input"
				v-model="inputText"
				placeholder="问我理财问题..."
				:disabled="isStreaming"
				@confirm="onSend"
				confirm-type="send"
			/>
			<view :class="['send-btn', !inputText.trim() || isStreaming ? 'disabled' : '']" @click="onSend">
				<text v-if="!isStreaming">发送</text>
				<text v-else>...</text>
			</view>
		</view>
	</view>
</template>

<script>
import { getToken } from '../../utils/auth.js'
import { BASE_URL } from '../../api/config.js'

export default {
	data() {
		return {
			messages: [],
			inputText: '',
			isStreaming: false,
			scrollTop: 0,
			suggestions: [
				'本月支出有什么需要注意的吗？',
				'如何制定下月预算？',
				'我的储蓄率合理吗？',
				'哪些支出可以优化？'
			],
			requestTask: null
		}
	},
	onUnload() {
		if (this.requestTask) {
			try { this.requestTask.abort() } catch (e) {}
		}
	},
	methods: {
		onSend() {
			const text = (this.inputText || '').trim()
			if (!text || this.isStreaming) return
			this.inputText = ''
			this.sendMessage(text)
		},

		async sendMessage(content) {
			if (this.isStreaming) return

			// 添加用户消息和占位的助手消息
			this.messages.push({ role: 'user', content })
			this.messages.push({ role: 'assistant', content: '', streaming: true })
			this.isStreaming = true
			this.scrollToBottom()

			const idx = this.messages.length - 1
			const token = getToken()

			try {
				// uni-app 的 request 不支持流式响应，需用 chunk receiver
				this.requestTask = uni.request({
					url: BASE_URL + '/app/fin/ai/chat/stream',
					method: 'POST',
					data: { message: content },
					header: {
						'Authorization': token ? 'Bearer ' + token : '',
						'Content-Type': 'application/json',
						'Accept': 'text/event-stream'
					},
					timeout: 60000,
					enableChunked: true,
					responseType: 'text',
					success: (res) => {
						// 非流式 fallback：整体接收
						if (res.statusCode === 200 && typeof res.data === 'string') {
							this.parseSSEText(res.data, idx)
						}
						this.finishStream(idx)
					},
					fail: (err) => {
						console.error('SSE error', err)
						this.messages[idx].content = '抱歉，连接失败：' + (err.errMsg || '未知错误')
						this.finishStream(idx)
					}
				})

				// 使用 onChunkReceived 接收流式数据
				if (this.requestTask && typeof this.requestTask.onChunkReceived === 'function') {
					let buffer = ''
					this.requestTask.onChunkReceived((chunk) => {
						const text = this.arrayBufferToString(chunk.data)
						buffer += text
						const events = this.extractSSEEvents(buffer)
						buffer = events.remainder
						for (const evt of events.events) {
							this.handleSSEEvent(evt, idx)
						}
					})
				}
			} catch (e) {
				console.error('Send message error', e)
				this.messages[idx].content = '错误：' + e.message
				this.finishStream(idx)
			}
		},

		arrayBufferToString(buffer) {
			if (typeof buffer === 'string') return buffer
			try {
				return new TextDecoder('utf-8').decode(new Uint8Array(buffer))
			} catch (e) {
				const bytes = new Uint8Array(buffer)
				let s = ''
				for (let i = 0; i < bytes.length; i++) s += String.fromCharCode(bytes[i])
				try { return decodeURIComponent(escape(s)) } catch (_) { return s }
			}
		},

		extractSSEEvents(buffer) {
			const events = []
			let remainder = buffer
			const blocks = buffer.split('\n\n')
			if (blocks.length > 1) {
				remainder = blocks.pop()
				for (const block of blocks) {
					if (block.trim()) events.push(block)
				}
			}
			return { events, remainder }
		},

		handleSSEEvent(rawEvent, idx) {
			const lines = rawEvent.split('\n')
			let event = 'message'
			let data = ''
			for (const line of lines) {
				if (line.startsWith('event:')) event = line.substring(6).trim()
				else if (line.startsWith('data:')) data += line.substring(5).trim()
			}

			if (!data) return

			try {
				const parsed = JSON.parse(data)
				if (event === 'delta' || parsed.type === 'delta') {
					const chunk = parsed.content || ''
					if (this.messages[idx]) {
						this.messages[idx].content = (this.messages[idx].content || '') + chunk
						this.messages = [...this.messages] // 触发响应式更新
						this.scrollToBottom()
					}
				} else if (event === 'complete' || parsed.done === true) {
					this.finishStream(idx)
				} else if (event === 'error') {
					if (this.messages[idx]) {
						this.messages[idx].content = '错误：' + (parsed.content || data)
						this.finishStream(idx)
					}
				}
			} catch (e) {
				// 非 JSON 数据
				if (this.messages[idx]) {
					this.messages[idx].content = (this.messages[idx].content || '') + data
				}
			}
		},

		parseSSEText(text, idx) {
			const blocks = text.split('\n\n')
			for (const block of blocks) {
				if (block.trim()) this.handleSSEEvent(block, idx)
			}
		},

		finishStream(idx) {
			if (this.messages[idx]) {
				this.messages[idx].streaming = false
				this.messages = [...this.messages]
			}
			this.isStreaming = false
			this.requestTask = null
			this.scrollToBottom()
		},

		scrollToBottom() {
			this.$nextTick(() => {
				this.scrollTop = 999999 + Math.random()
			})
		}
	}
}
</script>

<style scoped>
.ai-chat-page {
	display: flex;
	flex-direction: column;
	height: 100vh;
	background: #f0fdf4;
}

.messages {
	flex: 1;
	padding: 24rpx;
}

.empty {
	display: flex;
	flex-direction: column;
	align-items: center;
	padding: 80rpx 32rpx;
}

.empty-icon {
	font-size: 96rpx;
	margin-bottom: 16rpx;
}

.empty-title {
	font-size: 36rpx;
	font-weight: bold;
	color: #064e3b;
	margin-bottom: 8rpx;
}

.empty-desc {
	font-size: 26rpx;
	color: #6b7280;
	margin-bottom: 40rpx;
}

.suggestions {
	display: flex;
	flex-direction: column;
	gap: 16rpx;
	width: 100%;
}

.suggestion {
	background: #fff;
	padding: 24rpx;
	border-radius: 16rpx;
	border: 1rpx solid #d1fae5;
	font-size: 28rpx;
	color: #064e3b;
}

.msg-row {
	display: flex;
	margin-bottom: 24rpx;
}

.msg-row.user {
	justify-content: flex-end;
}

.msg-row.assistant {
	justify-content: flex-start;
}

.bubble {
	max-width: 80%;
	padding: 20rpx 28rpx;
	border-radius: 20rpx;
	word-break: break-word;
}

.user .bubble {
	background: #059669;
	color: #fff;
}

.assistant .bubble {
	background: #fff;
	color: #064e3b;
	border: 1rpx solid #d1fae5;
}

.content {
	font-size: 28rpx;
	line-height: 1.6;
	white-space: pre-wrap;
}

.thinking {
	display: flex;
	gap: 8rpx;
	padding: 8rpx 0;
}

.dot {
	width: 12rpx;
	height: 12rpx;
	border-radius: 50%;
	background: #059669;
	animation: bounce 1.4s ease-in-out infinite;
}

.dot:nth-child(2) { animation-delay: 0.2s; }
.dot:nth-child(3) { animation-delay: 0.4s; }

@keyframes bounce {
	0%, 80%, 100% { transform: scale(0.6); opacity: 0.5; }
	40% { transform: scale(1); opacity: 1; }
}

.input-area {
	display: flex;
	align-items: center;
	padding: 16rpx 24rpx;
	background: #fff;
	border-top: 1rpx solid #d1fae5;
	gap: 12rpx;
}

.input {
	flex: 1;
	background: #f0fdf4;
	border-radius: 32rpx;
	padding: 16rpx 24rpx;
	font-size: 28rpx;
}

.send-btn {
	background: #059669;
	color: #fff;
	padding: 16rpx 32rpx;
	border-radius: 32rpx;
	font-size: 28rpx;
}

.send-btn.disabled {
	background: #9ca3af;
}
</style>
