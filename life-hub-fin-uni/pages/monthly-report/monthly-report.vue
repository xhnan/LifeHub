<template>
	<view class="monthly-report">
		<view class="month-switcher">
			<view class="switch-btn" @click="prevMonth"><text class="switch-arrow">◀</text></view>
			<text class="switch-month">{{ year }}年{{ month }}月 财务报告</text>
			<view class="switch-btn" @click="nextMonth"><text class="switch-arrow">▶</text></view>
		</view>

		<view class="section">
			<HealthScore :savingRate="savingRate" :balance="monthBalance" />
		</view>
		<view class="section">
			<DailyTrend :dailyData="dailyExpenseTrend" />
		</view>
		<view class="section">
			<DonutChart :items="expenseCategories" />
		</view>
		<view class="section">
			<KeyMetrics
				:avgDailyExpense="avgDailyExpense"
				:maxExpense="maxExpense"
				:maxIncome="maxIncome"
				:totalDays="totalDays"
				:expenseCount="expenseCount"
				:incomeCount="incomeCount"
			/>
		</view>
		<view class="section">
			<TopTransactions :incomeTop="incomeTop3" :expenseTop="expenseTop3" />
		</view>
		<view class="section">
			<AiInsight
				:report="aiReport"
				:loading="aiLoading"
				:error="aiError"
				@refresh="loadAiInsight"
			/>
		</view>
		<view style="height: 40rpx;"></view>
	</view>
</template>

<script>
import HealthScore from '../../components/HealthScore/HealthScore.vue'
import DailyTrend from '../../components/DailyTrend/DailyTrend.vue'
import DonutChart from '../../components/DonutChart/DonutChart.vue'
import KeyMetrics from '../../components/KeyMetrics/KeyMetrics.vue'
import TopTransactions from '../../components/TopTransactions/TopTransactions.vue'
import AiInsight from '../../components/AiInsight/AiInsight.vue'
import { getMonthlyReport, getMonthlyAiInsight } from '../../api/index.js'
import { records as mockRecords } from '../../mock/data.js'

export default {
	components: { HealthScore, DailyTrend, DonutChart, KeyMetrics, TopTransactions, AiInsight },
	data() {
		const now = new Date()
		return {
			year: now.getFullYear(),
			month: now.getMonth() + 1,
			report: null,
			aiReport: null,
			aiLoading: false,
			aiError: ''
		}
	},
	computed: {
		monthRecords() {
			return mockRecords.filter(r => {
				const d = new Date(r.date)
				return d.getFullYear() === this.year && d.getMonth() + 1 === this.month
			})
		},
		totalIncome() { return this.monthRecords.filter(r => r.type === 'income').reduce((s, r) => s + r.amount, 0) },
		totalExpense() { return this.monthRecords.filter(r => r.type === 'expense').reduce((s, r) => s + r.amount, 0) },
		expenseCount() { return this.monthRecords.filter(r => r.type === 'expense').length },
		incomeCount() { return this.monthRecords.filter(r => r.type === 'income').length },
		monthBalance() { return this.totalIncome - this.totalExpense },
		savingRate() {
			if (this.totalIncome <= 0) return 0
			return Math.max((this.monthBalance / this.totalIncome) * 100, 0)
		},
		dailyExpenseTrend() {
			const daysInMonth = new Date(this.year, this.month, 0).getDate()
			const today = new Date()
			const isCurrentMonth = this.year === today.getFullYear() && this.month === today.getMonth() + 1
			const maxDay = isCurrentMonth ? today.getDate() : daysInMonth
			const result = []
			for (let d = 1; d <= maxDay; d++) {
				const dateStr = `${this.year}-${String(this.month).padStart(2, '0')}-${String(d).padStart(2, '0')}`
				const dayExpense = this.monthRecords.filter(r => r.date === dateStr && r.type === 'expense').reduce((s, r) => s + r.amount, 0)
				result.push({ label: `${d}`, amount: dayExpense })
			}
			return result
		},
		expenseCategories() {
			const map = {}
			this.monthRecords.forEach(r => {
				if (r.type !== 'expense') return
				if (!map[r.category]) map[r.category] = { name: r.category, icon: r.icon, amount: 0 }
				map[r.category].amount += r.amount
			})
			const total = this.totalExpense || 1
			return Object.values(map).sort((a, b) => b.amount - a.amount).map(c => ({ ...c, percent: (c.amount / total) * 100 }))
		},
		avgDailyExpense() {
			return this.totalDays === 0 ? 0 : this.totalExpense / this.totalDays
		},
		maxExpense() {
			const expenses = this.monthRecords.filter(r => r.type === 'expense')
			return expenses.length ? Math.max(...expenses.map(r => r.amount)) : 0
		},
		maxIncome() {
			const incomes = this.monthRecords.filter(r => r.type === 'income')
			return incomes.length ? Math.max(...incomes.map(r => r.amount)) : 0
		},
		totalDays() { return new Set(this.monthRecords.map(r => r.date)).size },
		incomeTop3() {
			return this.monthRecords.filter(r => r.type === 'income').sort((a, b) => b.amount - a.amount).slice(0, 3)
		},
		expenseTop3() {
			return this.monthRecords.filter(r => r.type === 'expense').sort((a, b) => b.amount - a.amount).slice(0, 3)
		}
	},
	onLoad(options) {
		if (options.year) this.year = parseInt(options.year)
		if (options.month) this.month = parseInt(options.month)
		this.loadData()
	},
	methods: {
		async loadData() {
			try {
				const res = await getMonthlyReport(this.year, this.month)
				// 如果 API 返回数据，用 API 数据覆盖
				if (res) this.report = res
			} catch (e) {
				// fallback 到 computed 中的 mock 数据
			}
			// 同时加载 AI 解读
			this.loadAiInsight()
		},
		async loadAiInsight() {
			this.aiLoading = true
			this.aiError = ''
			this.aiReport = null
			try {
				const res = await getMonthlyAiInsight(this.year, this.month)
				if (res) this.aiReport = res
			} catch (e) {
				this.aiError = e.message || 'AI 分析失败'
			} finally {
				this.aiLoading = false
			}
		},
		prevMonth() {
			if (this.month === 1) { this.month = 12; this.year-- } else { this.month-- }
			this.loadData()
		},
		nextMonth() {
			const now = new Date()
			if (this.year === now.getFullYear() && this.month === now.getMonth() + 1) return
			if (this.month === 12) { this.month = 1; this.year++ } else { this.month++ }
			this.loadData()
		}
	}
}
</script>

<style lang="scss" scoped>
.monthly-report { padding: 24rpx 24rpx 0 24rpx; }
.month-switcher { display: flex; justify-content: center; align-items: center; gap: 24rpx; padding: 16rpx 0 28rpx; }
.switch-btn { width: 56rpx; height: 56rpx; display: flex; align-items: center; justify-content: center; }
.switch-arrow { font-size: 24rpx; color: #666; }
.switch-month { font-size: 30rpx; font-weight: 600; color: #1a1a1a; }
.section { margin-bottom: 24rpx; }
</style>
