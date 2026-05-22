<template>
	<view class="snapshot-card">
		<view class="snapshot-header">
			<view class="header-left">
				<text class="snapshot-title">账户余额</text>
				<text class="snapshot-total money-font">{{ formatTotal }}</text>
			</view>
			<view class="eye-toggle" @click="showBalance = !showBalance">
				<text class="eye-icon">{{ showBalance ? '👁' : '👁‍🗨' }}</text>
			</view>
		</view>
		<view class="account-list">
			<view
				class="account-item pressable"
				v-for="account in accounts"
				:key="account.id"
				@click="$emit('click', account)"
			>
				<view class="account-left">
					<view class="account-icon-wrap" :class="getAccountType(account)">
						<DynIcon :icon="account.icon" :size="32" />
					</view>
					<view class="account-info">
						<text class="account-name">{{ account.name }}</text>
						<text class="account-type-tag">{{ getTypeLabel(account) }}</text>
					</view>
				</view>
				<text class="account-balance money-font" :class="account.balance >= 0 ? 'income-color' : 'expense-color'">
					{{ showBalance ? formatMoney(account.balance) : '****' }}
				</text>
			</view>
		</view>
		<view class="snapshot-footer" v-if="accounts.length > 4">
			<text class="footer-text">共 {{ accounts.length }} 个账户</text>
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
	data() {
		return {
			showBalance: true
		}
	},
	computed: {
		formatTotal() {
			const total = this.accounts.reduce((sum, a) => sum + a.balance, 0)
			if (!this.showBalance) return '¥****'
			return this.formatMoney(total)
		}
	},
	methods: {
		formatMoney(val) {
			if (val >= 0) {
				return '¥' + val.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
			}
			return '-¥' + Math.abs(val).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
		},
		getAccountType(account) {
			if (account.type === 'credit') return 'credit'
			if (account.type === 'investment') return 'invest'
			if (account.type === 'ewallet') return 'ewallet'
			return 'bank'
		},
		getTypeLabel(account) {
			const map = {
				bank: '储蓄卡',
				ewallet: '电子钱包',
				investment: '理财',
				credit: '信用'
			}
			return map[account.type] || ''
		}
	}
}
</script>

<style lang="scss" scoped>
.snapshot-card {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 28rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.snapshot-header {
	display: flex;
	justify-content: space-between;
	align-items: flex-start;
	margin-bottom: 24rpx;
}

.header-left {
	display: flex;
	flex-direction: column;
	gap: 6rpx;
}

.snapshot-title {
	font-size: 26rpx;
	color: #999;
}

.snapshot-total {
	font-size: 36rpx;
	font-weight: 700;
	color: #1a1a1a;
}

.eye-toggle {
	padding: 8rpx;
}

.eye-icon {
	font-size: 28rpx;
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

.account-icon-wrap {
	width: 64rpx;
	height: 64rpx;
	border-radius: 16rpx;
	display: flex;
	align-items: center;
	justify-content: center;

	&.bank {
		background: rgba(5, 150, 105, 0.08);
	}

	&.ewallet {
		background: rgba(14, 165, 233, 0.08);
	}

	&.invest {
		background: rgba(245, 158, 11, 0.08);
	}

	&.credit {
		background: rgba(239, 68, 68, 0.08);
	}
}

.account-info {
	display: flex;
	flex-direction: column;
	gap: 4rpx;
}

.account-name {
	font-size: 28rpx;
	color: #333;
	font-weight: 500;
}

.account-type-tag {
	font-size: 20rpx;
	color: #bbb;
}

.account-balance {
	font-size: 30rpx;
	font-weight: 600;
}

.snapshot-footer {
	text-align: center;
	padding-top: 16rpx;
	margin-top: 8rpx;
}

.footer-text {
	font-size: 22rpx;
	color: #ccc;
}
</style>
