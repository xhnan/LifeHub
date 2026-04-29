<template>
	<view class="daily-trend">
		<view class="trend-header">
			<text class="trend-title">每日支出走势</text>
			<view class="trend-legend">
				<view class="legend-dot" style="background:#ef4444;"></view>
				<text class="legend-text">支出</text>
			</view>
		</view>
		<view class="trend-body">
			<view class="trend-area">
				<view
					class="trend-bar"
					v-for="(item, index) in chartData"
					:key="index"
					:style="{ height: item.height + '%' }"
				>
					<text class="bar-tip" v-if="item.amount > 0">¥{{ item.amount.toFixed(0) }}</text>
				</view>
			</view>
			<view class="trend-labels">
				<text class="trend-label" v-for="(item, index) in chartData" :key="index">
					{{ showLabel(index) ? item.label : '' }}
				</text>
			</view>
		</view>
		<view class="trend-stats">
			<view class="stat-item">
				<text class="stat-label">日均支出</text>
				<text class="stat-value money-font expense-color">{{ formatMoney(avgDaily) }}</text>
			</view>
			<view class="stat-item">
				<text class="stat-label">最高单日</text>
				<text class="stat-value money-font">{{ formatMoney(maxDaily) }}</text>
			</view>
		</view>
	</view>
</template>

<script>
export default {
	name: 'DailyTrend',
	props: {
		dailyData: { type: Array, default: () => [] }
	},
	computed: {
		maxVal() {
			return Math.max(...this.dailyData.map(d => d.amount), 1)
		},
		chartData() {
			return this.dailyData.map(d => ({
				label: d.label,
				amount: d.amount,
				height: Math.max((d.amount / this.maxVal) * 100, d.amount > 0 ? 5 : 0)
			}))
		},
		avgDaily() {
			if (!this.dailyData.length) return 0
			const total = this.dailyData.reduce((s, d) => s + d.amount, 0)
			return total / this.dailyData.length
		},
		maxDaily() {
			return Math.max(...this.dailyData.map(d => d.amount), 0)
		}
	},
	methods: {
		showLabel(index) {
			// Show label every few days to avoid crowding
			const len = this.chartData.length
			if (len <= 10) return true
			const step = Math.ceil(len / 8)
			return index % step === 0 || index === len - 1
		},
		formatMoney(val) {
			return '¥' + val.toFixed(0)
		}
	}
}
</script>

<style lang="scss" scoped>
.daily-trend {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 28rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.trend-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 24rpx;
}

.trend-title {
	font-size: 30rpx;
	font-weight: 600;
	color: #1a1a1a;
}

.trend-legend {
	display: flex;
	align-items: center;
	gap: 8rpx;
}

.legend-dot {
	width: 14rpx;
	height: 14rpx;
	border-radius: 3rpx;
}

.legend-text {
	font-size: 22rpx;
	color: #999;
}

.trend-body {
	margin-bottom: 20rpx;
}

.trend-area {
	display: flex;
	align-items: flex-end;
	height: 200rpx;
	gap: 4rpx;
	background: linear-gradient(180deg, transparent 0%, rgba(239, 68, 68, 0.03) 100%);
	border-bottom: 1rpx solid #f5f5f5;
	padding-bottom: 2rpx;
}

.trend-bar {
	flex: 1;
	background: linear-gradient(180deg, #ef4444, #fca5a5);
	border-radius: 6rpx 6rpx 0 0;
	position: relative;
	min-width: 0;
}

.bar-tip {
	position: absolute;
	top: -24rpx;
	left: 50%;
	transform: translateX(-50%);
	font-size: 14rpx;
	color: #ef4444;
	white-space: nowrap;
	font-weight: 500;
}

.trend-labels {
	display: flex;
	gap: 4rpx;
}

.trend-label {
	flex: 1;
	text-align: center;
	font-size: 16rpx;
	color: #ccc;
	height: 28rpx;
	line-height: 28rpx;
}

.trend-stats {
	display: flex;
	gap: 24rpx;
	padding-top: 16rpx;
	border-top: 1rpx solid #f5f5f5;
}

.stat-item {
	display: flex;
	flex-direction: column;
	gap: 4rpx;
}

.stat-label {
	font-size: 22rpx;
	color: #999;
}

.stat-value {
	font-size: 26rpx;
	font-weight: 600;
	color: #1a1a1a;
}
</style>
