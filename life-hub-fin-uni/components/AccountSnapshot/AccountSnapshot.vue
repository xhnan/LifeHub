<template>
	<view class="snapshot-card">
		<view class="snapshot-header">
			<text class="snapshot-title">账户余额</text>
			<text class="snapshot-count">共 {{ accounts.length }} 个账户</text>
		</view>
		<view class="account-list">
			<view
				class="account-item"
				v-for="account in accounts"
				:key="account.id"
				@click="$emit('click', account)"
			>
				<view class="account-left">
					<DynIcon :icon="account.icon" :size="36" />
					<text class="account-name">{{ account.name }}</text>
				</view>
				<text class="account-balance money-font" :class="account.balance >= 0 ? 'income-color' : 'expense-color'">
					{{ formatMoney(account.balance) }}
				</text>
			</view>
		</view>
	</view>
</template>

<script>
import DynIcon from '../DynIcon/DynIcon.vue'

export default {
	name: 'AccountSnapshot',
	components: { DynIcon },
	props: {
		accounts: { type: Array, required: true }
	},
	emits: ['click'],
	methods: {
		formatMoney(val) {
			if (val >= 0) {
				return '¥' + val.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
			}
			return '-¥' + Math.abs(val).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
		}
	}
}
</script>

<style lang="scss" scoped>
.snapshot-card {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 32rpx 28rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.snapshot-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 24rpx;
}

.snapshot-title {
	font-size: 30rpx;
	font-weight: 600;
	color: #1a1a1a;
}

.snapshot-count {
	font-size: 24rpx;
	color: #999;
}

.account-list {
	display: flex;
	flex-direction: column;
}

.account-item {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 20rpx 0;
	border-bottom: 1rpx solid #f5f5f5;

	&:last-child {
		border-bottom: none;
		padding-bottom: 0;
	}

	&:first-child {
		padding-top: 0;
	}
}

.account-left {
	display: flex;
	align-items: center;
	gap: 16rpx;
}

.account-icon {
	font-size: 36rpx;
}

.account-name {
	font-size: 28rpx;
	color: #333;
}

.account-balance {
	font-size: 30rpx;
	font-weight: 600;
}
</style>
