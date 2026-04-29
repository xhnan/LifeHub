<template>
	<view class="key-metrics">
		<view class="metrics-title">关键指标</view>
		<view class="metrics-grid">
			<view class="metric-item">
				<text class="metric-value money-font">{{ formatMoney(avgDailyExpense) }}</text>
				<text class="metric-label">日均支出</text>
			</view>
			<view class="metric-item">
				<text class="metric-value money-font">{{ formatMoney(maxExpense) }}</text>
				<text class="metric-label">单笔最大支出</text>
			</view>
			<view class="metric-item">
				<text class="metric-value money-font income-color">{{ formatMoney(maxIncome) }}</text>
				<text class="metric-label">单笔最大收入</text>
			</view>
			<view class="metric-item">
				<text class="metric-value">{{ totalDays }}天</text>
				<text class="metric-label">有记录天数</text>
			</view>
			<view class="metric-item">
				<text class="metric-value">{{ expenseCount }}笔</text>
				<text class="metric-label">支出笔数</text>
			</view>
			<view class="metric-item">
				<text class="metric-value">{{ incomeCount }}笔</text>
				<text class="metric-label">收入笔数</text>
			</view>
		</view>
	</view>
</template>

<script>
export default {
	name: 'KeyMetrics',
	props: {
		avgDailyExpense: { type: Number, default: 0 },
		maxExpense: { type: Number, default: 0 },
		maxIncome: { type: Number, default: 0 },
		totalDays: { type: Number, default: 0 },
		expenseCount: { type: Number, default: 0 },
		incomeCount: { type: Number, default: 0 }
	},
	methods: {
		formatMoney(val) {
			if (val >= 10000) return (val / 10000).toFixed(1) + '万'
			return '¥' + val.toFixed(0)
		}
	}
}
</script>

<style lang="scss" scoped>
.key-metrics {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 28rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.metrics-title {
	font-size: 30rpx;
	font-weight: 600;
	color: #1a1a1a;
	margin-bottom: 20rpx;
}

.metrics-grid {
	display: flex;
	flex-wrap: wrap;
	gap: 16rpx;
}

.metric-item {
	width: calc(33.33% - 12rpx);
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 6rpx;
	padding: 16rpx 0;
}

.metric-value {
	font-size: 28rpx;
	font-weight: 700;
	color: #1a1a1a;
}

.metric-label {
	font-size: 20rpx;
	color: #999;
}
</style>
