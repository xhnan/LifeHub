<template>
	<view class="top-transactions">
		<view class="top-header">
			<text class="top-title">大额收支</text>
		</view>
		<view class="top-section">
			<view class="top-subtitle income-color">收入 TOP 3</view>
			<view class="top-item" v-for="(item, index) in incomeTop" :key="'i'+index">
				<view class="top-left">
					<view class="top-rank income-rank">{{ index + 1 }}</view>
					<DynIcon :icon="item.icon" :size="28" />
					<view class="top-info">
						<text class="top-category">{{ item.category }}</text>
						<text class="top-note">{{ item.note }}</text>
					</view>
				</view>
				<text class="top-amount money-font income-color">+{{ formatMoney(item.amount) }}</text>
			</view>
		</view>
		<view class="top-section">
			<view class="top-subtitle expense-color">支出 TOP 3</view>
			<view class="top-item" v-for="(item, index) in expenseTop" :key="'e'+index">
				<view class="top-left">
					<view class="top-rank expense-rank">{{ index + 1 }}</view>
					<DynIcon :icon="item.icon" :size="28" />
					<view class="top-info">
						<text class="top-category">{{ item.category }}</text>
						<text class="top-note">{{ item.note }}</text>
					</view>
				</view>
				<text class="top-amount money-font expense-color">-{{ formatMoney(item.amount) }}</text>
			</view>
		</view>
	</view>
</template>

<script>
import DynIcon from '../DynIcon/DynIcon.vue'

export default {
	name: 'TopTransactions',
	components: { DynIcon },
	props: {
		incomeTop: { type: Array, default: () => [] },
		expenseTop: { type: Array, default: () => [] }
	},
	methods: {
		formatMoney(val) {
			return '¥' + val.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
		}
	}
}
</script>

<style lang="scss" scoped>
.top-transactions {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 28rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.top-header {
	margin-bottom: 20rpx;
}

.top-title {
	font-size: 30rpx;
	font-weight: 600;
	color: #1a1a1a;
}

.top-section {
	margin-bottom: 20rpx;

	&:last-child {
		margin-bottom: 0;
	}
}

.top-subtitle {
	font-size: 24rpx;
	font-weight: 600;
	margin-bottom: 12rpx;
}

.top-item {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 12rpx 0;

	& + .top-item {
		border-top: 1rpx solid #f8f8f8;
	}
}

.top-left {
	display: flex;
	align-items: center;
	gap: 12rpx;
	flex: 1;
	min-width: 0;
}

.top-rank {
	width: 36rpx;
	height: 36rpx;
	border-radius: 8rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 20rpx;
	font-weight: 700;
	color: #fff;
	flex-shrink: 0;

	&.income-rank {
		background: #10b981;
	}
	&.expense-rank {
		background: #ef4444;
	}
}

.top-icon {
	font-size: 28rpx;
	flex-shrink: 0;
}

.top-info {
	display: flex;
	flex-direction: column;
	gap: 2rpx;
	min-width: 0;
}

.top-category {
	font-size: 26rpx;
	color: #333;
	font-weight: 500;
}

.top-note {
	font-size: 22rpx;
	color: #999;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.top-amount {
	font-size: 28rpx;
	font-weight: 600;
	flex-shrink: 0;
	margin-left: 16rpx;
}
</style>
