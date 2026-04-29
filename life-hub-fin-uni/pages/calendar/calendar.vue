<template>
	<view class="calendar-page">
		<CalendarGrid
			:dailySummary="dailySummary"
			:selectedDate="selectedDate"
			@monthChange="onMonthChange"
			@dateSelect="onDateSelect"
		/>
		<view class="section">
			<DaySummary :date="selectedDate" :records="selectedDayRecords" />
		</view>
		<view style="height: 40rpx;"></view>
	</view>
</template>

<script>
import CalendarGrid from '../../components/CalendarGrid/CalendarGrid.vue'
import DaySummary from '../../components/DaySummary/DaySummary.vue'
import { getCalendarSummary, getRecords } from '../../api/index.js'
import { records as mockRecords } from '../../mock/data.js'

export default {
	components: { CalendarGrid, DaySummary },
	data() {
		const today = new Date()
		return {
			allRecords: mockRecords,
			dailySummary: {},
			selectedDate: `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`,
			currentYear: today.getFullYear(),
			currentMonth: today.getMonth() + 1
		}
	},
	computed: {
		selectedDayRecords() {
			return this.allRecords
				.filter(r => r.date === this.selectedDate)
				.sort((a, b) => b.timestamp - a.timestamp)
		}
	},
	onShow() {
		this.loadMonthData(this.currentYear, this.currentMonth)
	},
	methods: {
		async loadMonthData(year, month) {
			const [summaryRes, recordsRes] = await Promise.allSettled([
				getCalendarSummary(year, month),
				getRecords({ startDate: `${year}-${String(month).padStart(2, '0')}-01` })
			])

			if (summaryRes.status === 'fulfilled') {
				this.dailySummary = summaryRes.value
			} else {
				// 从 mock 记录中计算日汇总
				const summary = {}
				mockRecords.forEach(r => {
					const d = new Date(r.date)
					if (d.getFullYear() === year && d.getMonth() + 1 === month) {
						if (!summary[r.date]) summary[r.date] = { income: 0, expense: 0 }
						if (r.type === 'income') summary[r.date].income += r.amount
						else summary[r.date].expense += r.amount
					}
				})
				this.dailySummary = summary
			}

			if (recordsRes.status === 'fulfilled') {
				this.allRecords = recordsRes.value.records || recordsRes.value
			} else {
				this.allRecords = mockRecords
			}
		},
		onMonthChange({ year, month }) {
			this.currentYear = year
			this.currentMonth = month
			this.loadMonthData(year, month)
		},
		onDateSelect(dateStr) {
			this.selectedDate = dateStr
		}
	}
}
</script>

<style lang="scss" scoped>
.calendar-page {
	padding: 24rpx;
}

.section {
	margin-top: 24rpx;
}
</style>
