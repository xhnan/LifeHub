<template>
	<view class="asset-card" :style="{ background: gradient }">
		<view class="card-label">{{ label }}</view>
		<view class="card-amount money-font">{{ formatMoney(amount) }}</view>
		<view class="card-change" v-if="change !== 0">
			<text class="change-arrow">{{ change > 0 ? '↑' : '↓' }}</text>
			<text class="change-value">{{ formatMoney(Math.abs(change)) }}</text>
			<text class="change-label">较昨日</text>
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
		type: { type: String, default: 'asset' } // asset, liability, networth
	},
	computed: {
		gradient() {
			const gradients = {
				asset: 'linear-gradient(135deg, #059669, #10b981)',
				liability: 'linear-gradient(135deg, #f59e0b, #fbbf24)',
				networth: 'linear-gradient(135deg, #0ea5e9, #38bdf8)'
			}
			return gradients[this.type] || gradients.asset
		}
	},
	methods: {
		formatMoney(val) {
			if (val === undefined || val === null) return '¥0.00'
			return '¥' + val.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
		}
	}
}
</script>

<style lang="scss" scoped>
.asset-card {
	border-radius: 20rpx;
	padding: 24rpx 20rpx;
	color: #ffffff;
	flex: 1;
	min-width: 0;
	box-sizing: border-box;
}

.card-label {
	font-size: 20rpx;
	opacity: 0.85;
	margin-bottom: 8rpx;
	letter-spacing: 1rpx;
}

.card-amount {
	font-size: 28rpx;
	font-weight: 700;
	margin-bottom: 10rpx;
	word-break: break-all;
}

.card-change {
	display: flex;
	align-items: center;
	gap: 4rpx;
	font-size: 18rpx;
	opacity: 0.85;
}

.change-arrow {
	font-size: 20rpx;
}

.change-label {
	margin-left: 4rpx;
	opacity: 0.7;
}
</style>
