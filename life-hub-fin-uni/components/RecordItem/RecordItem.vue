<template>
	<view class="record-item-wrap">
		<view
			class="record-item"
			@touchstart="onTouchStart"
			@touchmove="onTouchMove"
			@touchend="onTouchEnd"
			:style="{ transform: `translateX(${offsetX}rpx)` }"
			@click="showDetail"
		>
			<view class="record-left">
				<view class="record-icon-wrap" :class="record.type">
					<DynIcon :icon="record.icon" :size="36" />
				</view>
				<view class="record-info">
					<text class="record-category">{{ record.category }}</text>
					<text class="record-meta">
						<text class="record-note" v-if="record.note">{{ record.note }}</text>
						<text class="record-dot" v-if="record.note && record.account">·</text>
						<text class="record-account">{{ record.account }}</text>
					</text>
				</view>
			</view>
			<view class="record-right">
				<text
					class="record-amount money-font"
					:class="record.type === 'income' ? 'income-color' : 'expense-color'"
				>
					{{ record.type === 'income' ? '+' : '-' }}{{ formatMoney(record.amount) }}
				</text>
			</view>
		</view>
		<!-- 滑动删除按钮 -->
		<view class="swipe-actions" v-if="offsetX < -20">
			<view class="action-btn delete-btn" @click.stop="handleDelete">
				<text class="action-text">删除</text>
			</view>
		</view>
	</view>
</template>

<script>
import DynIcon from '../DynIcon/DynIcon.vue'

export default {
	name: 'RecordItem',
	components: { DynIcon },
	props: {
		record: { type: Object, required: true }
	},
	emits: ['delete', 'click'],
	data() {
		return {
			offsetX: 0,
			startX: 0,
			startY: 0,
			swiping: false
		}
	},
	methods: {
		formatMoney(val) {
			return '¥' + val.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
		},
		onTouchStart(e) {
			this.startX = e.touches[0].clientX
			this.startY = e.touches[0].clientY
			this.swiping = false
		},
		onTouchMove(e) {
			const dx = e.touches[0].clientX - this.startX
			const dy = e.touches[0].clientY - this.startY

			// 判断是否是水平滑动
			if (Math.abs(dx) > Math.abs(dy) && Math.abs(dx) > 10) {
				this.swiping = true
				// 只允许左滑
				if (dx < 0) {
					this.offsetX = Math.max(dx * 2, -160)
				} else if (this.offsetX < 0) {
					this.offsetX = Math.min(0, this.offsetX + dx * 2)
				}
			}
		},
		onTouchEnd() {
			if (this.offsetX < -80) {
				this.offsetX = -140
			} else {
				this.offsetX = 0
			}
		},
		handleDelete() {
			uni.showModal({
				title: '确认删除',
				content: `确定要删除这笔${this.record.type === 'income' ? '收入' : '支出'}记录吗？`,
				confirmColor: '#ef4444',
				success: (res) => {
					if (res.confirm) {
						this.$emit('delete', this.record)
						this.offsetX = 0
					} else {
						this.offsetX = 0
					}
				}
			})
		},
		showDetail() {
			if (this.swiping || this.offsetX !== 0) {
				this.offsetX = 0
				return
			}
			this.$emit('click', this.record)
		}
	}
}
</script>

<style lang="scss" scoped>
.record-item-wrap {
	position: relative;
	overflow: hidden;

	& + .record-item-wrap {
		border-top: 1rpx solid #f5f5f5;
	}
}

.record-item {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 24rpx 0;
	transition: transform 0.15s ease-out;
	background: #ffffff;
	position: relative;
	z-index: 1;
}

.record-left {
	display: flex;
	align-items: center;
	gap: 16rpx;
	flex: 1;
	min-width: 0;
}

.record-icon-wrap {
	width: 72rpx;
	height: 72rpx;
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
	flex-shrink: 0;

	&.expense {
		background: rgba(239, 68, 68, 0.08);
	}

	&.income {
		background: rgba(5, 150, 105, 0.08);
	}
}

.record-info {
	display: flex;
	flex-direction: column;
	gap: 6rpx;
	min-width: 0;
}

.record-category {
	font-size: 28rpx;
	color: #1a1a1a;
	font-weight: 500;
}

.record-meta {
	display: flex;
	align-items: center;
	gap: 0;
	font-size: 22rpx;
	color: #b0b0b0;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.record-note {
	font-size: 22rpx;
	color: #b0b0b0;
}

.record-dot {
	margin: 0 8rpx;
	color: #ddd;
}

.record-account {
	font-size: 22rpx;
	color: #ccc;
}

.record-right {
	flex-shrink: 0;
	margin-left: 16rpx;
}

.record-amount {
	font-size: 30rpx;
	font-weight: 600;
}

/* 滑动操作 */
.swipe-actions {
	position: absolute;
	right: 0;
	top: 0;
	bottom: 0;
	display: flex;
	align-items: center;
	z-index: 0;
}

.action-btn {
	height: 100%;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 0 32rpx;
}

.delete-btn {
	background: #ef4444;
	border-radius: 0 0 0 0;
}

.action-text {
	color: #ffffff;
	font-size: 26rpx;
	font-weight: 500;
}
</style>
