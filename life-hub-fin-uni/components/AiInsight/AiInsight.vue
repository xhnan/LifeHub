<template>
	<view class="ai-insight">
		<view class="header">
			<view class="title-row">
				<text class="ai-icon">✨</text>
				<text class="title">AI 智能解读</text>
				<view class="health-badge" v-if="report && report.healthScore">
					<text>{{ report.healthScore }}</text>
				</view>
			</view>
			<view class="refresh" @click="$emit('refresh')" v-if="!loading">
				<text class="refresh-icon">↻</text>
			</view>
		</view>

		<view class="loading" v-if="loading">
			<view class="loading-dots">
				<view class="dot"></view>
				<view class="dot"></view>
				<view class="dot"></view>
			</view>
			<text class="loading-text">AI 正在分析你的财务数据...</text>
		</view>

		<view class="error" v-else-if="error">
			<text class="error-text">{{ error }}</text>
			<view class="retry-btn" @click="$emit('refresh')">
				<text>重试</text>
			</view>
		</view>

		<view class="content" v-else-if="report">
			<!-- 叙述 -->
			<view class="narrative" v-if="report.narrative">
				<text class="narrative-text">{{ report.narrative }}</text>
			</view>

			<!-- 关键发现 -->
			<view class="section" v-if="report.keyFindings && report.keyFindings.length">
				<view class="section-header">
					<text class="section-icon">💡</text>
					<text class="section-title">关键发现</text>
				</view>
				<view class="bullet" v-for="(item, i) in report.keyFindings" :key="'f-' + i">
					<view class="dot blue"></view>
					<text class="bullet-text">{{ item }}</text>
				</view>
			</view>

			<!-- 建议 -->
			<view class="section" v-if="report.recommendations && report.recommendations.length">
				<view class="section-header">
					<text class="section-icon">📌</text>
					<text class="section-title">理财建议</text>
				</view>
				<view class="bullet" v-for="(item, i) in report.recommendations" :key="'r-' + i">
					<view class="dot green"></view>
					<text class="bullet-text">{{ item }}</text>
				</view>
			</view>

			<!-- 警示 -->
			<view class="section warning" v-if="report.warnings && report.warnings.length">
				<view class="section-header">
					<text class="section-icon">⚠️</text>
					<text class="section-title">注意事项</text>
				</view>
				<view class="bullet" v-for="(item, i) in report.warnings" :key="'w-' + i">
					<view class="dot orange"></view>
					<text class="bullet-text">{{ item }}</text>
				</view>
			</view>

			<!-- 预算建议 -->
			<view class="budget-tip" v-if="report.budgetSuggestion">
				<text class="tip-label">💰 下月预算</text>
				<text class="tip-text">{{ report.budgetSuggestion }}</text>
			</view>
		</view>

		<view class="empty" v-else>
			<text>点击右上角按钮生成 AI 分析</text>
		</view>
	</view>
</template>

<script>
export default {
	name: 'AiInsight',
	props: {
		report: { type: Object, default: null },
		loading: { type: Boolean, default: false },
		error: { type: String, default: '' }
	}
}
</script>

<style scoped>
.ai-insight {
	background: linear-gradient(135deg, #ecfdf5, #fff);
	border-radius: 24rpx;
	padding: 32rpx;
	box-shadow: 0 4rpx 16rpx rgba(5, 150, 105, 0.08);
}

.header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 24rpx;
}

.title-row {
	display: flex;
	align-items: center;
	gap: 12rpx;
}

.ai-icon { font-size: 36rpx; }

.title {
	font-size: 32rpx;
	font-weight: bold;
	color: #064e3b;
}

.health-badge {
	background: #059669;
	color: #fff;
	font-size: 22rpx;
	padding: 4rpx 16rpx;
	border-radius: 20rpx;
	min-width: 56rpx;
	text-align: center;
	font-weight: bold;
}

.refresh {
	width: 56rpx;
	height: 56rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	background: #d1fae5;
	border-radius: 50%;
}

.refresh-icon {
	font-size: 28rpx;
	color: #059669;
}

.loading {
	display: flex;
	flex-direction: column;
	align-items: center;
	padding: 60rpx 0;
}

.loading-dots {
	display: flex;
	gap: 12rpx;
	margin-bottom: 16rpx;
}

.dot {
	width: 16rpx;
	height: 16rpx;
	border-radius: 50%;
	background: #059669;
	animation: bounce 1.4s infinite;
}

.dot:nth-child(2) { animation-delay: 0.2s; }
.dot:nth-child(3) { animation-delay: 0.4s; }

.loading-text {
	font-size: 24rpx;
	color: #6b7280;
}

@keyframes bounce {
	0%, 80%, 100% { transform: scale(0.6); opacity: 0.4; }
	40% { transform: scale(1); opacity: 1; }
}

.error {
	display: flex;
	flex-direction: column;
	align-items: center;
	padding: 40rpx 0;
}

.error-text {
	font-size: 26rpx;
	color: #dc2626;
	margin-bottom: 16rpx;
}

.retry-btn {
	background: #059669;
	color: #fff;
	padding: 12rpx 32rpx;
	border-radius: 24rpx;
	font-size: 26rpx;
}

.narrative {
	background: #fff;
	padding: 24rpx;
	border-radius: 16rpx;
	margin-bottom: 24rpx;
	border-left: 6rpx solid #059669;
}

.narrative-text {
	font-size: 28rpx;
	line-height: 1.7;
	color: #1f2937;
}

.section {
	margin-bottom: 24rpx;
}

.section-header {
	display: flex;
	align-items: center;
	gap: 8rpx;
	margin-bottom: 12rpx;
}

.section-icon { font-size: 28rpx; }

.section-title {
	font-size: 28rpx;
	font-weight: bold;
	color: #064e3b;
}

.bullet {
	display: flex;
	align-items: flex-start;
	gap: 12rpx;
	padding: 8rpx 0;
}

.bullet .dot {
	width: 10rpx;
	height: 10rpx;
	border-radius: 50%;
	margin-top: 16rpx;
	flex-shrink: 0;
}

.dot.blue { background: #3b82f6; animation: none; }
.dot.green { background: #10b981; animation: none; }
.dot.orange { background: #f59e0b; animation: none; }

.bullet-text {
	font-size: 26rpx;
	line-height: 1.6;
	color: #374151;
	flex: 1;
}

.section.warning {
	background: #fef3c7;
	padding: 16rpx;
	border-radius: 12rpx;
}

.budget-tip {
	background: #fef9c3;
	border-radius: 16rpx;
	padding: 20rpx;
	margin-top: 16rpx;
}

.tip-label {
	font-size: 24rpx;
	font-weight: bold;
	color: #92400e;
	display: block;
	margin-bottom: 8rpx;
}

.tip-text {
	font-size: 26rpx;
	color: #78350f;
	line-height: 1.6;
}

.empty {
	text-align: center;
	padding: 40rpx 0;
	color: #9ca3af;
	font-size: 26rpx;
}
</style>
