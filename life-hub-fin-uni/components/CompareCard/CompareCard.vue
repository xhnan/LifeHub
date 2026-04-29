<template>
	<view class="compare-card">
		<view class="card-title">环比分析</view>
		<view class="compare-items">
			<view class="compare-item">
				<view class="compare-header">
					<text class="compare-label">收入</text>
					<view class="compare-badge" :class="incomeChange >= 0 ? 'up' : 'down'">
						<text class="badge-arrow">{{ incomeChange >= 0 ? '↑' : '↓' }}</text>
						<text class="badge-value">{{ Math.abs(incomeChange).toFixed(1) }}%</text>
					</view>
				</view>
				<view class="compare-bars">
					<view class="compare-row">
						<text class="row-label">本月</text>
						<view class="bar-track">
							<view class="bar-fill current-income" :style="{ width: incomePercent + '%' }"></view>
						</view>
						<text class="row-value">{{ shortMoney(currentIncome) }}</text>
					</view>
					<view class="compare-row">
						<text class="row-label">上月</text>
						<view class="bar-track">
							<view class="bar-fill prev-income" :style="{ width: prevIncomePercent + '%' }"></view>
						</view>
						<text class="row-value">{{ shortMoney(prevIncome) }}</text>
					</view>
				</view>
			</view>

			<view class="compare-divider"></view>

			<view class="compare-item">
				<view class="compare-header">
					<text class="compare-label">支出</text>
					<view class="compare-badge" :class="expenseChange >= 0 ? 'up' : 'down'">
						<text class="badge-arrow">{{ expenseChange >= 0 ? '↑' : '↓' }}</text>
						<text class="badge-value">{{ Math.abs(expenseChange).toFixed(1) }}%</text>
					</view>
				</view>
				<view class="compare-bars">
					<view class="compare-row">
						<text class="row-label">本月</text>
						<view class="bar-track">
							<view class="bar-fill current-expense" :style="{ width: expensePercent + '%' }"></view>
						</view>
						<text class="row-value">{{ shortMoney(currentExpense) }}</text>
					</view>
					<view class="compare-row">
						<text class="row-label">上月</text>
						<view class="bar-track">
							<view class="bar-fill prev-expense" :style="{ width: prevExpensePercent + '%' }"></view>
						</view>
						<text class="row-value">{{ shortMoney(prevExpense) }}</text>
					</view>
				</view>
			</view>
		</view>
	</view>
</template>

<script>
export default {
	name: 'CompareCard',
	props: {
		currentIncome: { type: Number, default: 0 },
		prevIncome: { type: Number, default: 0 },
		currentExpense: { type: Number, default: 0 },
		prevExpense: { type: Number, default: 0 }
	},
	computed: {
		maxVal() {
			return Math.max(this.currentIncome, this.prevIncome, this.currentExpense, this.prevExpense, 1)
		},
		incomePercent() {
			return (this.currentIncome / this.maxVal) * 100
		},
		prevIncomePercent() {
			return (this.prevIncome / this.maxVal) * 100
		},
		expensePercent() {
			return (this.currentExpense / this.maxVal) * 100
		},
		prevExpensePercent() {
			return (this.prevExpense / this.maxVal) * 100
		},
		incomeChange() {
			if (this.prevIncome === 0) return this.currentIncome > 0 ? 100 : 0
			return ((this.currentIncome - this.prevIncome) / this.prevIncome) * 100
		},
		expenseChange() {
			if (this.prevExpense === 0) return this.currentExpense > 0 ? 100 : 0
			return ((this.currentExpense - this.prevExpense) / this.prevExpense) * 100
		}
	},
	methods: {
		shortMoney(val) {
			if (val >= 10000) return (val / 10000).toFixed(1) + '万'
			return '¥' + val.toFixed(0)
		}
	}
}
</script>

<style lang="scss" scoped>
.compare-card {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 28rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.card-title {
	font-size: 30rpx;
	font-weight: 600;
	color: #1a1a1a;
	margin-bottom: 24rpx;
}

.compare-items {
	display: flex;
	flex-direction: column;
	gap: 24rpx;
}

.compare-divider {
	height: 1rpx;
	background: #f5f5f5;
}

.compare-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 16rpx;
}

.compare-label {
	font-size: 26rpx;
	color: #666;
	font-weight: 500;
}

.compare-badge {
	display: flex;
	align-items: center;
	gap: 4rpx;
	padding: 4rpx 12rpx;
	border-radius: 12rpx;
	font-size: 22rpx;

	&.up {
		background: rgba(5, 150, 105, 0.1);
		color: #059669;
	}
	&.down {
		background: rgba(239, 68, 68, 0.1);
		color: #ef4444;
	}
}

.compare-bars {
	display: flex;
	flex-direction: column;
	gap: 12rpx;
}

.compare-row {
	display: flex;
	align-items: center;
	gap: 12rpx;
}

.row-label {
	font-size: 22rpx;
	color: #999;
	width: 56rpx;
	flex-shrink: 0;
}

.bar-track {
	flex: 1;
	height: 16rpx;
	background: #f3f4f6;
	border-radius: 8rpx;
	overflow: hidden;
}

.bar-fill {
	height: 100%;
	border-radius: 8rpx;
	transition: width 0.3s;
}

.current-income { background: linear-gradient(90deg, #10b981, #6ee7b7); }
.prev-income { background: #d1fae5; }
.current-expense { background: linear-gradient(90deg, #ef4444, #fca5a5); }
.prev-expense { background: #fee2e2; }

.row-value {
	font-size: 22rpx;
	color: #666;
	width: 80rpx;
	text-align: right;
	flex-shrink: 0;
}
</style>
