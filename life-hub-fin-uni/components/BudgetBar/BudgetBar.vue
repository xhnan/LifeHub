<template>
	<view class="budget-bar" v-if="budget > 0">
		<view class="budget-header">
			<text class="budget-title">本月预算</text>
			<text class="budget-ratio money-font" :class="overBudget ? 'expense-color' : 'income-color'">
				{{ formatMoney(spent) }} / {{ formatMoney(budget) }}
			</text>
		</view>
		<view class="progress-track">
			<view
				class="progress-fill"
				:style="{ width: Math.min(percentage, 100) + '%' }"
				:class="{ warning: percentage > 80, danger: percentage > 100 }"
			></view>
		</view>
		<view class="budget-footer">
			<text class="budget-percent" :class="overBudget ? 'expense-color' : ''">
				已用 {{ percentage.toFixed(0) }}%
			</text>
			<text class="budget-remain" v-if="!overBudget">
				剩余 ¥{{ (budget - spent).toFixed(0) }}
			</text>
			<text class="budget-remain expense-color" v-else>
				超支 ¥{{ (spent - budget).toFixed(0) }}
			</text>
		</view>
	</view>
</template>

<script>
export default {
	name: 'BudgetBar',
	props: {
		budget: { type: Number, default: 0 },
		spent: { type: Number, default: 0 }
	},
	computed: {
		percentage() {
			if (this.budget <= 0) return 0
			return (this.spent / this.budget) * 100
		},
		overBudget() {
			return this.spent > this.budget
		}
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
.budget-bar {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 28rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.budget-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 16rpx;
}

.budget-title {
	font-size: 28rpx;
	font-weight: 600;
	color: #1a1a1a;
}

.budget-ratio {
	font-size: 24rpx;
	font-weight: 600;
}

.progress-track {
	height: 20rpx;
	background: #f3f4f6;
	border-radius: 10rpx;
	overflow: hidden;
}

.progress-fill {
	height: 100%;
	background: linear-gradient(90deg, #10b981, #059669);
	border-radius: 10rpx;
	transition: width 0.3s ease;

	&.warning {
		background: linear-gradient(90deg, #f59e0b, #d97706);
	}

	&.danger {
		background: linear-gradient(90deg, #ef4444, #dc2626);
	}
}

.budget-footer {
	display: flex;
	justify-content: space-between;
	margin-top: 12rpx;
}

.budget-percent {
	font-size: 22rpx;
	color: #666;
}

.budget-remain {
	font-size: 22rpx;
	color: #059669;
}
</style>
