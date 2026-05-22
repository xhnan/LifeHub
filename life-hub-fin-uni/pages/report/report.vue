<template>
	<view class="report-page">
		<view class="month-switcher">
			<view class="switch-btn" @click="prevMonth">
				<text class="switch-arrow">◀</text>
			</view>
			<text class="switch-month">{{ year }}年{{ month }}月</text>
			<view class="switch-btn" @click="nextMonth">
				<text class="switch-arrow">▶</text>
			</view>
		</view>

		<view class="section">
			<MonthSummary
				:income="monthData.income"
				:expense="monthData.expense"
				:incomeCount="monthData.incomeCount"
				:expenseCount="monthData.expenseCount"
			/>
		</view>

		<view class="section">
			<CompareCard
				:currentIncome="monthData.income"
				:prevIncome="prevMonthData.income"
				:currentExpense="monthData.expense"
				:prevExpense="prevMonthData.expense"
			/>
		</view>

		<view class="section">
			<RankList :items="expenseRank" :total="monthData.expense" type="expense" />
		</view>

		<view class="section">
			<RankList :items="incomeRank" :total="monthData.income" type="income" />
		</view>

		<view class="section">
			<view class="report-btn" @click="goMonthlyReport">
				<text class="report-btn-text">查看完整月度报告 →</text>
			</view>
		</view>

		<view style="height: 40rpx;"></view>
	</view>
</template>

<script>
import MonthSummary from '../../components/MonthSummary/MonthSummary.vue'
import CompareCard from '../../components/CompareCard/CompareCard.vue'
import RankList from '../../components/RankList/RankList.vue'
import { getMonthlySummary, getMonthlyRank } from '../../api/index.js'
import { records as mockRecords } from '../../mock/data.js'

export default {
	components: { MonthSummary, CompareCard, RankList },
	data() {
		const now = new Date()
		return { year: now.getFullYear(), month: now.getMonth() + 1 }
	},
	computed: {
		monthRecords() {
			return mockRecords.filter(r => {
				const d = new Date(r.date)
				return d.getFullYear() === this.year && d.getMonth() + 1 === this.month
			})
		},
		prevYear() { return this.month === 1 ? this.year - 1 : this.year },
		prevMonthVal() { return this.month === 1 ? 12 : this.month - 1 },
		prevMonthRecords() {
			return mockRecords.filter(r => {
				const d = new Date(r.date)
				return d.getFullYear() === this.prevYear && d.getMonth() + 1 === this.prevMonthVal
			})
		},
		monthData() { return this.calcSummary(this.monthRecords) },
		prevMonthData() { return this.calcSummary(this.prevMonthRecords) },
		expenseRank() { return this.calcRank(this.monthRecords, 'expense') },
		incomeRank() { return this.calcRank(this.monthRecords, 'income') }
	},
	onShow() {
		this.loadData()
	},
	onPullDownRefresh() {
		this.loadData().finally(() => {
			uni.stopPullDownRefresh()
		})
	},
	methods: {
		async loadData() {
			const [summaryRes, expRankRes, incRankRes] = await Promise.allSettled([
				getMonthlySummary(this.year, this.month),
				getMonthlyRank(this.year, this.month, 'expense'),
				getMonthlyRank(this.year, this.month, 'income')
			])
			// API 返回时已在 computed 中优先使用，这里保留 mock 作为 fallback
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
		},
		calcSummary(recs) {
			return {
				income: recs.filter(r => r.type === 'income').reduce((s, r) => s + r.amount, 0),
				expense: recs.filter(r => r.type === 'expense').reduce((s, r) => s + r.amount, 0),
				incomeCount: recs.filter(r => r.type === 'income').length,
				expenseCount: recs.filter(r => r.type === 'expense').length
			}
		},
		calcRank(recs, type) {
			const map = {}
			recs.forEach(r => {
				if (r.type !== type) return
				if (!map[r.category]) map[r.category] = { name: r.category, icon: r.icon, amount: 0 }
				map[r.category].amount += r.amount
			})
			const total = Object.values(map).reduce((s, c) => s + c.amount, 0) || 1
			return Object.values(map).sort((a, b) => b.amount - a.amount).map(c => ({ ...c, percent: (c.amount / total) * 100 }))
		},
		goMonthlyReport() {
			uni.navigateTo({ url: `/pages/monthly-report/monthly-report?year=${this.year}&month=${this.month}` })
		}
	}
}
</script>

<style lang="scss" scoped>
.report-page { padding: 24rpx 24rpx 0 24rpx; }
.month-switcher { display: flex; justify-content: center; align-items: center; gap: 32rpx; padding: 16rpx 0 24rpx; }
.switch-btn { width: 56rpx; height: 56rpx; display: flex; align-items: center; justify-content: center; }
.switch-arrow { font-size: 24rpx; color: #666; }
.switch-month { font-size: 32rpx; font-weight: 600; color: #1a1a1a; }
.section { margin-bottom: 24rpx; }
.report-btn { background: linear-gradient(135deg, #059669, #10b981); border-radius: 20rpx; padding: 28rpx; text-align: center; box-shadow: 0 4rpx 16rpx rgba(5, 150, 105, 0.25); }
.report-btn-text { color: #ffffff; font-size: 30rpx; font-weight: 600; }
</style>
