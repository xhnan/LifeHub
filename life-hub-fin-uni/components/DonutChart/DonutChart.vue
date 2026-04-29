<template>
	<view class="donut-chart">
		<view class="donut-header">
			<text class="donut-title">支出构成</text>
		</view>
		<view class="donut-body">
			<view class="donut-wrap">
				<view class="donut-ring">
					<!-- 中心文字 -->
					<view class="donut-center">
						<text class="donut-center-label">总支出</text>
						<text class="donut-center-val money-font">{{ shortMoney(total) }}</text>
					</view>
				</view>
				<!-- 分段指示条 -->
				<view class="donut-segments">
					<view
						class="segment"
						v-for="(item, index) in segments"
						:key="index"
						:style="{ width: item.percent + '%', background: colors[index % colors.length] }"
					></view>
				</view>
			</view>
			<!-- 分类列表 -->
			<view class="donut-list">
				<view class="donut-item" v-for="(item, index) in items.slice(0, 5)" :key="index">
					<view class="item-left">
						<view class="item-dot" :style="{ background: colors[index % colors.length] }"></view>
						<DynIcon :icon="item.icon" :size="26" />
						<text class="item-name">{{ item.name }}</text>
					</view>
					<view class="item-right">
						<text class="item-amount money-font">{{ formatMoney(item.amount) }}</text>
						<text class="item-percent">{{ item.percent.toFixed(1) }}%</text>
					</view>
				</view>
			</view>
		</view>
	</view>
</template>

<script>
import DynIcon from '../DynIcon/DynIcon.vue'

export default {
	name: 'DonutChart',
	components: { DynIcon },
	props: {
		items: { type: Array, default: () => [] }
	},
	data() {
		return {
			colors: ['#059669', '#0ea5e9', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899', '#06b6d4', '#84cc16']
		}
	},
	computed: {
		total() {
			return this.items.reduce((s, c) => s + c.amount, 0)
		},
		segments() {
			const total = this.total || 1
			return this.items.map(c => ({
				...c,
				percent: (c.amount / total) * 100
			}))
		}
	},
	methods: {
		formatMoney(val) {
			return '¥' + val.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
		},
		shortMoney(val) {
			if (val >= 10000) return (val / 10000).toFixed(1) + '万'
			return '¥' + val.toFixed(0)
		}
	}
}
</script>

<style lang="scss" scoped>
.donut-chart {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 28rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.donut-header {
	margin-bottom: 20rpx;
}

.donut-title {
	font-size: 30rpx;
	font-weight: 600;
	color: #1a1a1a;
}

.donut-body {
	display: flex;
	flex-direction: column;
	align-items: center;
}

.donut-wrap {
	width: 100%;
	margin-bottom: 24rpx;
}

.donut-ring {
	width: 200rpx;
	height: 200rpx;
	border-radius: 50%;
	border: 24rpx solid #f3f4f6;
	margin: 0 auto 20rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	position: relative;
}

.donut-center {
	display: flex;
	flex-direction: column;
	align-items: center;
}

.donut-center-label {
	font-size: 20rpx;
	color: #999;
}

.donut-center-val {
	font-size: 28rpx;
	font-weight: 700;
	color: #1a1a1a;
}

.donut-segments {
	display: flex;
	height: 16rpx;
	border-radius: 8rpx;
	overflow: hidden;
}

.segment {
	height: 100%;
	transition: width 0.3s;
}

.donut-list {
	width: 100%;
}

.donut-item {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 12rpx 0;

	& + .donut-item {
		border-top: 1rpx solid #f8f8f8;
	}
}

.item-left {
	display: flex;
	align-items: center;
	gap: 10rpx;
}

.item-dot {
	width: 14rpx;
	height: 14rpx;
	border-radius: 4rpx;
	flex-shrink: 0;
}

.item-icon {
	font-size: 26rpx;
}

.item-name {
	font-size: 26rpx;
	color: #333;
}

.item-right {
	display: flex;
	align-items: center;
	gap: 12rpx;
}

.item-amount {
	font-size: 26rpx;
	color: #1a1a1a;
	font-weight: 500;
}

.item-percent {
	font-size: 22rpx;
	color: #999;
	min-width: 70rpx;
	text-align: right;
}
</style>
