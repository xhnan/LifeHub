<template>
	<view class="day-summary" v-if="records.length > 0">
		<view class="summary-header">
			<text class="summary-date">{{ displayDate }}</text>
			<view class="summary-totals">
				<text class="summary-income money-font">收 {{ formatMoney(dayIncome) }}</text>
				<text class="summary-expense money-font">支 {{ formatMoney(dayExpense) }}</text>
			</view>
		</view>
		<view class="summary-records">
			<RecordItem v-for="record in records" :key="record.id" :record="record" />
		</view>
	</view>
	<view class="day-summary empty" v-else>
		<text class="empty-text">当日无收支记录</text>
	</view>
</template>

<script>
import RecordItem from '../RecordItem/RecordItem.vue'

export default {
	name: 'DaySummary',
	components: { RecordItem },
	props: {
		date: { type: String, required: true },
		records: { type: Array, default: () => [] }
	},
	computed: {
		displayDate() {
			const d = new Date(this.date)
			const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
			return `${d.getMonth() + 1}月${d.getDate()}日 ${weekDays[d.getDay()]}`
		},
		dayIncome() {
			return this.records
				.filter(r => r.type === 'income')
				.reduce((sum, r) => sum + r.amount, 0)
		},
		dayExpense() {
			return this.records
				.filter(r => r.type === 'expense')
				.reduce((sum, r) => sum + r.amount, 0)
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
.day-summary {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 28rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.summary-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 20rpx;
}

.summary-date {
	font-size: 30rpx;
	font-weight: 600;
	color: #1a1a1a;
}

.summary-totals {
	display: flex;
	gap: 20rpx;
}

.summary-income {
	font-size: 26rpx;
	color: #059669;
	font-weight: 500;
}

.summary-expense {
	font-size: 26rpx;
	color: #ef4444;
	font-weight: 500;
}

.empty {
	display: flex;
	align-items: center;
	justify-content: center;
	min-height: 120rpx;
}

.empty-text {
	color: #ccc;
	font-size: 28rpx;
}
</style>
