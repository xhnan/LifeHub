<template>
	<view class="category-chart">
		<view class="chart-header">
			<text class="chart-title">本月支出分类</text>
			<text class="chart-total money-font">共 {{ formatMoney(totalExpense) }}</text>
		</view>

		<view class="category-list">
			<view class="category-item" v-for="(item, index) in categoryData" :key="index">
				<view class="category-top">
					<view class="category-left">
						<DynIcon :icon="item.icon" :size="28" />
						<text class="category-name">{{ item.name }}</text>
					</view>
					<view class="category-right">
						<text class="category-amount money-font">{{ formatMoney(item.amount) }}</text>
						<text class="category-percent">{{ item.percent.toFixed(1) }}%</text>
					</view>
				</view>
				<view class="progress-bg">
					<view
						class="progress-fill"
						:style="{ width: item.percent + '%', background: colors[index % colors.length] }"
					></view>
				</view>
			</view>
		</view>
	</view>
</template>

<script>
import DynIcon from '../DynIcon/DynIcon.vue'

export default {
	name: 'CategoryChart',
	components: { DynIcon },
	props: {
		categories: { type: Array, default: () => [] }
	},
	data() {
		return {
			colors: [
				'#059669', '#0ea5e9', '#f59e0b', '#ef4444',
				'#8b5cf6', '#ec4899', '#06b6d4', '#84cc16',
				'#f97316', '#6366f1'
			]
		}
	},
	computed: {
		totalExpense() {
			return this.categories.reduce((sum, c) => sum + c.amount, 0)
		},
		categoryData() {
			const total = this.totalExpense || 1
			return this.categories.map(c => ({
				...c,
				percent: (c.amount / total) * 100
			}))
		}
	},
	methods: {
		formatMoney(val) {
			return '¥' + val.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
		}
	}
}
</script>

<style lang="scss" scoped>
.category-chart {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 28rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.chart-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 24rpx;
}

.chart-title {
	font-size: 30rpx;
	font-weight: 600;
	color: #1a1a1a;
}

.chart-total {
	font-size: 26rpx;
	color: #666;
}

.category-list {
	display: flex;
	flex-direction: column;
	gap: 20rpx;
}

.category-item {
	// each item
}

.category-top {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 10rpx;
}

.category-left {
	display: flex;
	align-items: center;
	gap: 10rpx;
}

.category-icon {
	font-size: 28rpx;
}

.category-name {
	font-size: 26rpx;
	color: #333;
}

.category-right {
	display: flex;
	align-items: center;
	gap: 12rpx;
}

.category-amount {
	font-size: 26rpx;
	color: #1a1a1a;
	font-weight: 500;
}

.category-percent {
	font-size: 22rpx;
	color: #999;
	min-width: 70rpx;
	text-align: right;
}

.progress-bg {
	height: 12rpx;
	background: #f3f4f6;
	border-radius: 6rpx;
	overflow: hidden;
}

.progress-fill {
	height: 100%;
	border-radius: 6rpx;
	transition: width 0.3s ease;
}
</style>
