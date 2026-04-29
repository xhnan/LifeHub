<template>
	<view class="rank-list">
		<view class="rank-title">
			<text class="rank-title-text">{{ type === 'expense' ? '支出' : '收入' }}排行榜</text>
			<text class="rank-total money-font">{{ formatMoney(total) }}</text>
		</view>
		<view class="rank-items">
			<view class="rank-item" v-for="(item, index) in items" :key="index">
				<view class="rank-left">
					<view class="rank-number" :class="{ 'top3': index < 3 }">
						<text class="rank-num-text">{{ index + 1 }}</text>
					</view>
					<DynIcon :icon="item.icon" :size="30" />
					<text class="rank-name">{{ item.name }}</text>
				</view>
				<view class="rank-right">
					<text class="rank-amount money-font">{{ formatMoney(item.amount) }}</text>
					<text class="rank-percent">{{ item.percent.toFixed(1) }}%</text>
				</view>
			</view>
		</view>
	</view>
</template>

<script>
import DynIcon from '../DynIcon/DynIcon.vue'

export default {
	name: 'RankList',
	components: { DynIcon },
	props: {
		items: { type: Array, default: () => [] },
		total: { type: Number, default: 0 },
		type: { type: String, default: 'expense' }
	},
	methods: {
		formatMoney(val) {
			return '¥' + val.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
		}
	}
}
</script>

<style lang="scss" scoped>
.rank-list {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 28rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.rank-title {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 20rpx;
}

.rank-title-text {
	font-size: 30rpx;
	font-weight: 600;
	color: #1a1a1a;
}

.rank-total {
	font-size: 26rpx;
	color: #666;
}

.rank-items {
	display: flex;
	flex-direction: column;
}

.rank-item {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 16rpx 0;

	& + .rank-item {
		border-top: 1rpx solid #f8f8f8;
	}
}

.rank-left {
	display: flex;
	align-items: center;
	gap: 12rpx;
}

.rank-number {
	width: 40rpx;
	height: 40rpx;
	border-radius: 10rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	background: #f3f4f6;

	&.top3 {
		background: linear-gradient(135deg, #f59e0b, #fbbf24);
	}
}

.rank-num-text {
	font-size: 22rpx;
	font-weight: 700;
	color: #999;

	.top3 & {
		color: #ffffff;
	}
}

.top3 .rank-num-text {
	color: #ffffff;
}

.rank-icon {
	font-size: 30rpx;
}

.rank-name {
	font-size: 26rpx;
	color: #333;
}

.rank-right {
	display: flex;
	align-items: center;
	gap: 12rpx;
}

.rank-amount {
	font-size: 26rpx;
	color: #1a1a1a;
	font-weight: 500;
}

.rank-percent {
	font-size: 22rpx;
	color: #999;
	min-width: 70rpx;
	text-align: right;
}
</style>
