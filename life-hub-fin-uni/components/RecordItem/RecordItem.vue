<template>
	<view class="record-item">
		<view class="record-left">
			<DynIcon :icon="record.icon" :size="40" />
			<view class="record-info">
				<text class="record-category">{{ record.category }}</text>
				<text class="record-note" v-if="record.note">{{ record.note }}</text>
			</view>
		</view>
		<view class="record-right">
			<text
				class="record-amount money-font"
				:class="record.type === 'income' ? 'income-color' : 'expense-color'"
			>
				{{ record.type === 'income' ? '+' : '-' }}{{ formatMoney(record.amount) }}
			</text>
			<text class="record-account">{{ record.account }}</text>
		</view>
	</view>
</template>

<script>
import DynIcon from '../DynIcon/DynIcon.vue'

export default {
	name: 'RecordItem',
	components: { DynIcon },
	props: {
		record: { type: Object, required: true }
	},
	methods: {
		formatMoney(val) {
			return '¥' + val.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
		}
	}
}
</script>

<style lang="scss" scoped>
.record-item {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 20rpx 0;

	& + .record-item {
		border-top: 1rpx solid #f5f5f5;
	}
}

.record-left {
	display: flex;
	align-items: center;
	gap: 16rpx;
	flex: 1;
	min-width: 0;
}

.record-icon {
	font-size: 40rpx;
	flex-shrink: 0;
}

.record-info {
	display: flex;
	flex-direction: column;
	gap: 4rpx;
	min-width: 0;
}

.record-category {
	font-size: 28rpx;
	color: #1a1a1a;
	font-weight: 500;
}

.record-note {
	font-size: 24rpx;
	color: #999;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.record-right {
	display: flex;
	flex-direction: column;
	align-items: flex-end;
	gap: 4rpx;
	flex-shrink: 0;
	margin-left: 20rpx;
}

.record-amount {
	font-size: 30rpx;
	font-weight: 600;
}

.record-account {
	font-size: 22rpx;
	color: #bbb;
}
</style>
