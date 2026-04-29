<template>
	<view class="trend-chart">
		<view class="chart-header">
			<text class="chart-title">近7日收支趋势</text>
			<view class="chart-legend">
				<view class="legend-item">
					<view class="legend-dot" style="background:#10b981;"></view>
					<text class="legend-text">收入</text>
				</view>
				<view class="legend-item">
					<view class="legend-dot" style="background:#ef4444;"></view>
					<text class="legend-text">支出</text>
				</view>
			</view>
		</view>

		<!-- 柱状图 -->
		<view class="chart-body">
			<view class="chart-bars">
				<view class="bar-group" v-for="(item, index) in chartData" :key="index">
					<view class="bar-pair">
						<view class="bar income-bar" :style="{ height: item.incomeHeight + '%' }">
							<text class="bar-value income-color" v-if="item.income > 0">{{ shortMoney(item.income) }}</text>
						</view>
						<view class="bar expense-bar" :style="{ height: item.expenseHeight + '%' }">
							<text class="bar-value expense-color" v-if="item.expense > 0">{{ shortMoney(item.expense) }}</text>
						</view>
					</view>
					<text class="bar-label">{{ item.label }}</text>
				</view>
			</view>
		</view>
	</view>
</template>

<script>
export default {
	name: 'TrendChart',
	props: {
		dailyData: { type: Array, default: () => [] }
	},
	computed: {
		chartData() {
			if (!this.dailyData.length) return []
			const maxVal = Math.max(...this.dailyData.map(d => Math.max(d.income, d.expense)), 1)
			return this.dailyData.map(d => ({
				label: d.label,
				income: d.income,
				expense: d.expense,
				incomeHeight: Math.max((d.income / maxVal) * 100, d.income > 0 ? 8 : 0),
				expenseHeight: Math.max((d.expense / maxVal) * 100, d.expense > 0 ? 8 : 0)
			}))
		}
	},
	methods: {
		shortMoney(val) {
			if (val >= 10000) return (val / 10000).toFixed(1) + '万'
			if (val >= 1000) return (val / 1000).toFixed(1) + 'k'
			return val.toFixed(0)
		}
	}
}
</script>

<style lang="scss" scoped>
.trend-chart {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 28rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.chart-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 28rpx;
}

.chart-title {
	font-size: 30rpx;
	font-weight: 600;
	color: #1a1a1a;
}

.chart-legend {
	display: flex;
	gap: 20rpx;
}

.legend-item {
	display: flex;
	align-items: center;
	gap: 8rpx;
}

.legend-dot {
	width: 16rpx;
	height: 16rpx;
	border-radius: 4rpx;
}

.legend-text {
	font-size: 22rpx;
	color: #999;
}

.chart-body {
	height: 300rpx;
}

.chart-bars {
	display: flex;
	align-items: flex-end;
	height: 240rpx;
	gap: 8rpx;
}

.bar-group {
	flex: 1;
	display: flex;
	flex-direction: column;
	align-items: center;
	height: 100%;
}

.bar-pair {
	flex: 1;
	display: flex;
	align-items: flex-end;
	justify-content: center;
	gap: 4rpx;
	width: 100%;
}

.bar {
	width: 24rpx;
	border-radius: 8rpx 8rpx 0 0;
	position: relative;
	transition: height 0.3s ease;
}

.income-bar {
	background: linear-gradient(180deg, #10b981, #a7f3d0);
}

.expense-bar {
	background: linear-gradient(180deg, #ef4444, #fca5a5);
}

.bar-value {
	position: absolute;
	top: -28rpx;
	left: 50%;
	transform: translateX(-50%);
	font-size: 16rpx;
	white-space: nowrap;
	font-weight: 500;
}

.bar-label {
	font-size: 20rpx;
	color: #999;
	margin-top: 8rpx;
}
</style>
