<template>
	<view class="calendar-grid">
		<!-- 月份导航 -->
		<view class="month-nav">
			<view class="nav-btn" @click="prevMonth">
				<text class="nav-arrow">◀</text>
			</view>
			<view class="month-center" @click="goToday">
				<text class="month-text">{{ currentYear }}年{{ currentMonth }}月</text>
				<text class="today-btn" v-if="!isCurrentMonth">回到今天</text>
			</view>
			<view class="nav-btn" @click="nextMonth">
				<text class="nav-arrow">▶</text>
			</view>
		</view>

		<!-- 星期头 -->
		<view class="week-header">
			<text class="week-day" v-for="day in weekDays" :key="day">{{ day }}</text>
		</view>

		<!-- 日历网格 -->
		<view class="days-grid">
			<view
				class="day-cell"
				v-for="(cell, index) in calendarCells"
				:key="index"
				:class="{
					'other-month': !cell.currentMonth,
					'is-today': cell.isToday,
					'is-selected': cell.dateStr === selectedDate
				}"
				@click="selectDate(cell)"
			>
				<text class="day-number">{{ cell.day }}</text>
				<view class="day-indicators" v-if="cell.currentMonth && getDayData(cell.dateStr)">
					<text class="indicator income-dot" v-if="getDayData(cell.dateStr).income > 0"></text>
					<text class="indicator expense-dot" v-if="getDayData(cell.dateStr).expense > 0"></text>
				</view>
			</view>
		</view>
	</view>
</template>

<script>
export default {
	name: 'CalendarGrid',
	props: {
		dailySummary: { type: Object, default: () => ({}) },
		selectedDate: { type: String, default: '' }
	},
	emits: ['monthChange', 'dateSelect'],
	data() {
		return {
			currentYear: new Date().getFullYear(),
			currentMonth: new Date().getMonth() + 1,
			weekDays: ['一', '二', '三', '四', '五', '六', '日']
		}
	},
	computed: {
		isCurrentMonth() {
			const now = new Date()
			return this.currentYear === now.getFullYear() && this.currentMonth === now.getMonth() + 1
		},
		calendarCells() {
			const cells = []
			const firstDay = new Date(this.currentYear, this.currentMonth - 1, 1)
			const lastDay = new Date(this.currentYear, this.currentMonth, 0)
			const daysInMonth = lastDay.getDate()

			// 周一为第一天 (0=Mon, 6=Sun)
			let startWeekday = firstDay.getDay() - 1
			if (startWeekday < 0) startWeekday = 6

			// 上月填充
			const prevMonthLastDay = new Date(this.currentYear, this.currentMonth - 1, 0).getDate()
			for (let i = startWeekday - 1; i >= 0; i--) {
				const day = prevMonthLastDay - i
				const prevMonth = this.currentMonth === 1 ? 12 : this.currentMonth - 1
				const prevYear = this.currentMonth === 1 ? this.currentYear - 1 : this.currentYear
				cells.push({
					day,
					currentMonth: false,
					dateStr: `${prevYear}-${String(prevMonth).padStart(2, '0')}-${String(day).padStart(2, '0')}`,
					isToday: false
				})
			}

			// 当月
			const today = new Date()
			const todayStr = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`

			for (let d = 1; d <= daysInMonth; d++) {
				const dateStr = `${this.currentYear}-${String(this.currentMonth).padStart(2, '0')}-${String(d).padStart(2, '0')}`
				cells.push({
					day: d,
					currentMonth: true,
					dateStr,
					isToday: dateStr === todayStr
				})
			}

			// 下月填充
			const remaining = 42 - cells.length
			for (let i = 1; i <= remaining; i++) {
				const nextMonth = this.currentMonth === 12 ? 1 : this.currentMonth + 1
				const nextYear = this.currentMonth === 12 ? this.currentYear + 1 : this.currentYear
				cells.push({
					day: i,
					currentMonth: false,
					dateStr: `${nextYear}-${String(nextMonth).padStart(2, '0')}-${String(i).padStart(2, '0')}`,
					isToday: false
				})
			}

			return cells
		}
	},
	methods: {
		getDayData(dateStr) {
			return this.dailySummary[dateStr] || null
		},
		prevMonth() {
			if (this.currentMonth === 1) {
				this.currentMonth = 12
				this.currentYear--
			} else {
				this.currentMonth--
			}
			this.$emit('monthChange', { year: this.currentYear, month: this.currentMonth })
		},
		nextMonth() {
			if (this.currentMonth === 12) {
				this.currentMonth = 1
				this.currentYear++
			} else {
				this.currentMonth++
			}
			this.$emit('monthChange', { year: this.currentYear, month: this.currentMonth })
		},
		goToday() {
			const now = new Date()
			this.currentYear = now.getFullYear()
			this.currentMonth = now.getMonth() + 1
			this.$emit('monthChange', { year: this.currentYear, month: this.currentMonth })
		},
		selectDate(cell) {
			if (!cell.currentMonth) return
			this.$emit('dateSelect', cell.dateStr)
		}
	}
}
</script>

<style lang="scss" scoped>
.calendar-grid {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 28rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.month-nav {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 28rpx;
}

.nav-btn {
	width: 64rpx;
	height: 64rpx;
	display: flex;
	align-items: center;
	justify-content: center;
}

.nav-arrow {
	font-size: 24rpx;
	color: #666;
}

.month-center {
	display: flex;
	flex-direction: column;
	align-items: center;
}

.month-text {
	font-size: 32rpx;
	font-weight: 600;
	color: #1a1a1a;
}

.today-btn {
	font-size: 22rpx;
	color: #0ea5e9;
	margin-top: 4rpx;
}

.week-header {
	display: flex;
	margin-bottom: 16rpx;
}

.week-day {
	flex: 1;
	text-align: center;
	font-size: 24rpx;
	color: #999;
	font-weight: 500;
}

.days-grid {
	display: flex;
	flex-wrap: wrap;
}

.day-cell {
	width: calc(100% / 7);
	height: 90rpx;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	position: relative;
}

.day-number {
	font-size: 28rpx;
	color: #1a1a1a;
}

.other-month .day-number {
	color: #ddd;
}

.is-today .day-number {
	background: #0ea5e9;
	color: #ffffff;
	width: 48rpx;
	height: 48rpx;
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 26rpx;
}

.is-selected .day-number {
	background: #059669;
	color: #ffffff;
	width: 48rpx;
	height: 48rpx;
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 26rpx;
}

.is-today.is-selected .day-number {
	background: #059669;
}

.day-indicators {
	display: flex;
	gap: 6rpx;
	position: absolute;
	bottom: 6rpx;
}

.indicator {
	width: 10rpx;
	height: 10rpx;
	border-radius: 50%;
}

.income-dot {
	background: #10b981;
}

.expense-dot {
	background: #ef4444;
}
</style>
