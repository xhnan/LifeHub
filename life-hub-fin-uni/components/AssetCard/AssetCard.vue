<template>
	<view class="asset-card" :style="{ background: gradient }">
		<view class="card-top">
			<text class="card-label">{{ label }}</text>
			<text class="card-indicator">{{ typeIcon }}</text>
		</view>
		<view class="card-amount money-font">{{ formatMoney(amount) }}</view>
		<view class="card-change" v-if="change !== 0">
			<text class="change-badge" :class="change > 0 ? 'up' : 'down'">
				{{ change > 0 ? '↑' : '↓' }} {{ shortChange }}
			</text>
		</view>
		<view class="card-change" v-else>
			<text class="change-badge neutral">— 持平</text>
		</view>
	</view>
</template>

<script>
export default {
	name: 'AssetCard',
	props: {
		label: { type: String, required: true },
		amount: { type: Number, required: true },
		change: { type: Number, default: 0 },
		type: { type: String, default: 'asset' }
	},
	computed: {
		gradient() {
			const gradients = {
				asset: 'linear-gradient(145deg, #059669 0%, #10b981 60%, #34d399 100%)',
				liability: 'linear-gradient(145deg, #d97706 0%, #f59e0b 60%, #fbbf24 100%)',
				networth: 'linear-gradient(145deg, #0369a1 0%, #0ea5e9 60%, #38bdf8 100%)'
			}
			return gradients[this.type] || gradients.asset
		},
		typeIcon() {
			const icons = { asset: '📈', liability: '📉', networth: '💎' }
			return icons[this.type] || '📊'
		},
		shortChange() {
			const abs = Math.abs(this.change)
			if (abs >= 10000) return (abs / 10000).toFixed(1) + '万'
			if (abs >= 1000) return (abs / 1000).toFixed(1) + 'k'
			return abs.toFixed(0)
		}
	},
	methods: {
		formatMoney(val) {
			if (val === undefined || val === null) return '¥0'
			const abs = Math.abs(val)
			if (abs >= 100000) return '¥' + (val / 10000).toFixed(1) + '万'
			return '¥' + val.toFixed(0).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
		}
	}
}
</script>

<style lang="scss" scoped>
.asset-card {
	border-radius: 20rpx;
	padding: 20rpx 16rpx;
	color: #ffffff;
	flex: 1;
	min-width: 0;
	box-sizing: border-box;
	position: relative;
	overflow: hidden;
}

.card-top {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 12rpx;
}

.card-label {
	font-size: 20rpx;
	opacity: 0.85;
	letter-spacing: 1rpx;
}

.card-indicator {
	font-size: 18rpx;
	opacity: 0.6;
}

.card-amount {
	font-size: 28rpx;
	font-weight: 700;
	margin-bottom: 8rpx;
	word-break: break-all;
	line-height: 1.2;
}

.card-change {
	display: flex;
	align-items: center;
}

.change-badge {
	font-size: 18rpx;
	padding: 2rpx 10rpx;
	border-radius: 8rpx;
	background: rgba(255, 255, 255, 0.2);

	&.up {
		background: rgba(255, 255, 255, 0.25);
	}

	&.down {
		background: rgba(0, 0, 0, 0.1);
	}

	&.neutral {
		opacity: 0.6;
		background: transparent;
	}
}
</style>
