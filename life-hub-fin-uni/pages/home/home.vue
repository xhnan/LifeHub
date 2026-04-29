<template>
	<view class="home-page">
		<!-- 用户信息栏 -->
		<view class="user-bar" @click="goProfile">
			<view class="user-left">
				<view class="user-avatar">{{ userAvatar }}</view>
				<view class="user-info">
					<text class="user-name">{{ userName }}</text>
					<text class="user-greeting">{{ greeting }}</text>
				</view>
			</view>
			<text class="user-arrow">›</text>
		</view>

		<!-- 资产卡片 -->
		<view class="asset-cards">
			<AssetCard class="asset-card-item"
				label="总资产"
				:amount="overview.totalAsset"
				:change="overview.assetChange"
				type="asset"
			/>
			<AssetCard class="asset-card-item"
				label="总负债"
				:amount="overview.totalLiability"
				:change="overview.liabilityChange"
				type="liability"
			/>
			<AssetCard class="asset-card-item"
				label="净资产"
				:amount="overview.netWorth"
				:change="overview.netWorthChange"
				type="networth"
			/>
		</view>

		<!-- 近7日收支趋势 -->
		<view class="section">
			<TrendChart :dailyData="trendData" />
		</view>

		<!-- 本月支出分类 -->
		<view class="section">
			<CategoryChart :categories="expenseCategories" />
		</view>

		<!-- 账户余额快照 -->
		<view class="section">
			<AccountSnapshot :accounts="accounts" @click="onAccountClick" />
		</view>

		<view style="height: 40rpx;"></view>
	</view>
</template>

<script>
import AssetCard from '../../components/AssetCard/AssetCard.vue'
import AccountSnapshot from '../../components/AccountSnapshot/AccountSnapshot.vue'
import TrendChart from '../../components/TrendChart/TrendChart.vue'
import CategoryChart from '../../components/CategoryChart/CategoryChart.vue'
import { getUser } from '../../utils/auth.js'
import { getOverview, getAccounts, getTrend, getExpenseCategories } from '../../api/index.js'
import { assetOverview as mockOverview, accounts as mockAccounts, records as mockRecords } from '../../mock/data.js'

export default {
	components: { AssetCard, AccountSnapshot, TrendChart, CategoryChart },
	data() {
		return {
			overview: { totalAsset: 0, totalLiability: 0, netWorth: 0, assetChange: 0, liabilityChange: 0, netWorthChange: 0 },
			accounts: [],
			trendData: [],
			expenseCategories: []
		}
	},
	computed: {
		user() { return getUser() || {} },
		userName() { return this.user.nickname || this.user.username || '未登录' },
		userAvatar() { return this.user.avatar || '🧑' },
		greeting() {
			const h = new Date().getHours()
			if (h < 6) return '夜深了，注意休息'
			if (h < 9) return '早上好，新的一天'
			if (h < 12) return '上午好，加油'
			if (h < 14) return '中午好，记得吃饭'
			if (h < 18) return '下午好'
			if (h < 22) return '晚上好'
			return '夜深了，注意休息'
		}
	},
	onShow() {
		this.loadData()
	},
	methods: {
		async loadData() {
			// 并行请求，失败 fallback 到 mock
			const [overviewRes, accountsRes, trendRes, categoriesRes] = await Promise.allSettled([
				getOverview(),
				getAccounts(),
				getTrend(7),
				getExpenseCategories()
			])

			this.overview = overviewRes.status === 'fulfilled' ? overviewRes.value : mockOverview
			this.accounts = accountsRes.status === 'fulfilled' ? accountsRes.value : mockAccounts

			if (trendRes.status === 'fulfilled') {
				this.trendData = trendRes.value.map(d => ({
					label: d.date.slice(5).replace('-', '/'),
					income: d.income,
					expense: d.expense
				}))
			} else {
				this.trendData = this.mockTrend()
			}

			if (categoriesRes.status === 'fulfilled') {
				this.expenseCategories = categoriesRes.value
			} else {
				this.expenseCategories = this.mockExpenseCategories()
			}
		},
		mockTrend() {
			const days = []
			for (let i = 6; i >= 0; i--) {
				const d = new Date()
				d.setDate(d.getDate() - i)
				const dateStr = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
				const dayRecords = mockRecords.filter(r => r.date === dateStr)
				days.push({
					label: `${d.getMonth() + 1}/${d.getDate()}`,
					income: dayRecords.filter(r => r.type === 'income').reduce((s, r) => s + r.amount, 0),
					expense: dayRecords.filter(r => r.type === 'expense').reduce((s, r) => s + r.amount, 0)
				})
			}
			return days
		},
		mockExpenseCategories() {
			const map = {}
			mockRecords.forEach(r => {
				if (r.type !== 'expense') return
				if (!map[r.category]) map[r.category] = { name: r.category, icon: r.icon, amount: 0 }
				map[r.category].amount += r.amount
			})
			return Object.values(map).sort((a, b) => b.amount - a.amount).slice(0, 6)
		},
		onAccountClick(account) {
			console.log('点击账户:', account.name)
		},
		goProfile() {
			uni.navigateTo({ url: '/pages/profile/profile' })
		}
	}
}
</script>

<style lang="scss" scoped>
.home-page {
	padding: 24rpx 24rpx 0 24rpx;
}

.user-bar {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 12rpx 0 24rpx;
}

.user-left {
	display: flex;
	align-items: center;
	gap: 16rpx;
}

.user-avatar {
	width: 72rpx;
	height: 72rpx;
	border-radius: 50%;
	background: linear-gradient(135deg, #10b981, #6ee7b7);
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 36rpx;
}

.user-info {
	display: flex;
	flex-direction: column;
	gap: 4rpx;
}

.user-name {
	font-size: 30rpx;
	font-weight: 600;
	color: #1a1a1a;
}

.user-greeting {
	font-size: 22rpx;
	color: #999;
}

.user-arrow {
	font-size: 36rpx;
	color: #ccc;
}

.asset-cards {
	display: flex;
	gap: 12rpx;
}

.asset-card-item {
	flex: 1;
	width: 0;
	min-width: 0;
}

.section {
	margin-top: 24rpx;
}
</style>
