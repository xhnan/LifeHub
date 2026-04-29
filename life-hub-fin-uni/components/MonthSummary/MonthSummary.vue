<template>
	<view class="month-summary">
		<view class="summary-row">
			<view class="summary-item income">
				<text class="item-label">本月收入</text>
				<text class="item-amount money-font">{{ formatMoney(income) }}</text>
				<text class="item-count">{{ incomeCount }}笔</text>
			</view>
			<view class="summary-divider"></view>
			<view class="summary-item expense">
				<text class="item-label">本月支出</text>
				<text class="item-amount money-font">{{ formatMoney(expense) }}</text>
				<text class="item-count">{{ expenseCount }}笔</text>
			</view>
		</view>
		<view class="summary-bottom">
			<view class="balance-row">
				<text class="balance-label">本月结余</text>
				<text class="balance-amount money-font" :class="balance >= 0 ? 'income-color' : 'expense-color'">
					{{ balance >= 0 ? '+' : '' }}{{ formatMoney(balance) }}
				</text>
			</view>
			<view class="saving-bar" v-if="income > 0">
				<view class="saving-fill" :style="{ width: savingRate + '%' }"></view>
				<text class="saving-text">储蓄率 {{ savingRate.toFixed(1) }}%</text>
			</view>
		</view>
	</view>
</template>

<script>
export default {
	name: 'MonthSummary',
	props: {
		income: { type: Number, default: 0 },
		expense: { type: Number, default: 0 },
		incomeCount: { type: Number, default: 0 },
		expenseCount: { type: Number, default: 0 }
	},
	computed: {
		balance() {
			return this.income - this.expense
		},
		savingRate() {
			if (this.income <= 0) return 0
			return Math.max(((this.income - this.expense) / this.income) * 100, 0)
		}
	},
	methods: {
		formatMoney(val) {
			const abs = Math.abs(val)
			return '¥' + abs.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
		}
	}
}
</script>

<style lang="scss" scoped>
.month-summary {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 32rpx 28rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.summary-row {
	display: flex;
	align-items: center;
}

.summary-item {
	flex: 1;
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 8rpx;
}

.summary-divider {
	width: 1rpx;
	height: 80rpx;
	background: #f0f0f0;
}

.item-label {
	font-size: 24rpx;
	color: #999;
}

.income .item-amount {
	color: #059669;
	font-size: 36rpx;
	font-weight: 700;
}

.expense .item-amount {
	color: #ef4444;
	font-size: 36rpx;
	font-weight: 700;
}

.item-count {
	font-size: 22rpx;
	color: #ccc;
}

.summary-bottom {
	margin-top: 24rpx;
	padding-top: 24rpx;
	border-top: 1rpx solid #f5f5f5;
}

.balance-row {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 16rpx;
}

.balance-label {
	font-size: 26rpx;
	color: #666;
}

.balance-amount {
	font-size: 32rpx;
	font-weight: 700;
}

.saving-bar {
	height: 16rpx;
	background: #f3f4f6;
	border-radius: 8rpx;
	overflow: hidden;
	position: relative;
}

.saving-fill {
	height: 100%;
	background: linear-gradient(90deg, #10b981, #059669);
	border-radius: 8rpx;
	transition: width 0.3s;
}

.saving-text {
	position: absolute;
	right: 0;
	top: 24rpx;
	font-size: 20rpx;
	color: #999;
}
</style>
