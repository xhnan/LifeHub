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
			<view class="user-right">
				<view class="notification-dot" v-if="hasNotification"></view>
				<text class="user-arrow">›</text>
			</view>
		</view>

		<!-- 加载骨架屏 -->
		<view class="skeleton-wrap" v-if="loading">
			<view class="skeleton-cards">
				<view class="skeleton-card" v-for="i in 3" :key="i"></view>
			</view>
			<view class="skeleton-block tall"></view>
			<view class="skeleton-block"></view>
		</view>

		<template v-else>

		<!-- 首次使用欢迎引导 -->
		<view class="welcome-card" v-if="showWelcome" @click="dismissWelcome">
			<view class="welcome-content">
				<text class="welcome-emoji">👋</text>
				<view class="welcome-text">
					<text class="welcome-title">欢迎使用 LifeHub</text>
					<text class="welcome-desc">点击右下角 "+" 开始记录你的第一笔收支</text>
				</view>
			</view>
			<text class="welcome-close">✕</text>
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

		<!-- 预算进度 -->
		<view class="section" v-if="monthlyBudget > 0">
			<BudgetBar :budget="monthlyBudget" :spent="monthlySpent" />
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
		</template>

		<view style="height: 140rpx;"></view>

		<!-- 浮动 AI 按钮 -->
		<view class="ai-fab-btn" @click="goAiChat">
			<text class="ai-fab-icon">✨</text>
		</view>

		<!-- 浮动记账按钮 -->
		<view class="fab-btn" @click="goAddRecord">
			<text class="fab-icon">+</text>
		</view>
	</view>
</template>

<script>
import AssetCard from '../../components/AssetCard/AssetCard.vue'
import AccountSnapshot from '../../components/AccountSnapshot/AccountSnapshot.vue'
import TrendChart from '../../components/TrendChart/TrendChart.vue'
import CategoryChart from '../../components/CategoryChart/CategoryChart.vue'
import BudgetBar from '../../components/BudgetBar/BudgetBar.vue'
import { getUser } from '../../utils/auth.js'
import { getOverview, getAccounts, getTrend, getExpenseCategories } from '../../api/index.js'
import { assetOverview as mockOverview, accounts as mockAccounts, records as mockRecords } from '../../mock/data.js'

export default {
	components: { AssetCard, AccountSnapshot, TrendChart, CategoryChart, BudgetBar },
	data() {
		return {
			loading: true,
			showWelcome: false,
			overview: { totalAsset: 0, totalLiability: 0, netWorth: 0, assetChange: 0, liabilityChange: 0, netWorthChange: 0 },
			accounts: [],
			trendData: [],
			expenseCategories: [],
			monthlyBudget: 0,
			monthlySpent: 0
		}
	},
	computed: {
		user() { return getUser() || {} },
		userName() { return this.user.nickname || this.user.username || '未登录' },
		userAvatar() { return this.user.avatar || '🧑' },
		hasNotification() { return false },
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
	onPullDownRefresh() {
		this.loadData().finally(() => {
			uni.stopPullDownRefresh()
		})
	},
	methods: {
		async loadData() {
			this.loading = true
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

			// 计算本月支出 & 读取预算设置
			this.monthlySpent = this.calcMonthlySpent()
			this.loadBudget()

			// 首次使用判断
			if (!uni.getStorageSync('lifehub_welcomed')) {
				this.showWelcome = true
			}

			this.loading = false
		},
		loadBudget() {
			try {
				const settings = uni.getStorageSync('lifehub_settings')
				if (settings) {
					const parsed = JSON.parse(settings)
					this.monthlyBudget = parseFloat(parsed.monthlyBudget) || 0
				}
			} catch (e) {}
		},
		calcMonthlySpent() {
			const now = new Date()
			const year = now.getFullYear()
			const month = now.getMonth() + 1
			return mockRecords
				.filter(r => {
					if (r.type !== 'expense') return false
					const d = new Date(r.date)
					return d.getFullYear() === year && d.getMonth() + 1 === month
				})
				.reduce((s, r) => s + r.amount, 0)
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
		},
		goAddRecord() {
			uni.navigateTo({ url: '/pages/add-record/add-record' })
		},
		goAiChat() {
			uni.navigateTo({ url: '/pages/ai-chat/ai-chat' })
		},
		dismissWelcome() {
			this.showWelcome = false
			uni.setStorageSync('lifehub_welcomed', 'true')
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

.user-right {
	display: flex;
	align-items: center;
	gap: 12rpx;
	position: relative;
}

.notification-dot {
	width: 16rpx;
	height: 16rpx;
	border-radius: 50%;
	background: #ef4444;
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

.fab-btn {
	position: fixed;
	right: 40rpx;
	bottom: 180rpx;
	width: 100rpx;
	height: 100rpx;
	border-radius: 50%;
	background: linear-gradient(135deg, #059669, #10b981);
	box-shadow: 0 8rpx 32rpx rgba(5, 150, 105, 0.4);
	display: flex;
	align-items: center;
	justify-content: center;
	z-index: 999;
}

.fab-icon {
	font-size: 52rpx;
	color: #ffffff;
	font-weight: 300;
	line-height: 1;
}

.ai-fab-btn {
	position: fixed;
	right: 40rpx;
	bottom: 300rpx;
	width: 88rpx;
	height: 88rpx;
	border-radius: 50%;
	background: linear-gradient(135deg, #8b5cf6, #6366f1);
	box-shadow: 0 8rpx 32rpx rgba(99, 102, 241, 0.4);
	display: flex;
	align-items: center;
	justify-content: center;
	z-index: 999;
}

.ai-fab-icon {
	font-size: 40rpx;
	line-height: 1;
}

/* 骨架屏 */
.skeleton-wrap {
	margin-top: 24rpx;
}

/* 欢迎卡片 */
.welcome-card {
	display: flex;
	align-items: center;
	justify-content: space-between;
	background: linear-gradient(135deg, #f0fdf4, #ecfdf5);
	border: 2rpx solid #d1fae5;
	border-radius: 20rpx;
	padding: 24rpx 28rpx;
	margin-bottom: 20rpx;
}

.welcome-content {
	display: flex;
	align-items: center;
	gap: 16rpx;
}

.welcome-emoji {
	font-size: 36rpx;
}

.welcome-text {
	display: flex;
	flex-direction: column;
	gap: 4rpx;
}

.welcome-title {
	font-size: 26rpx;
	font-weight: 600;
	color: #059669;
}

.welcome-desc {
	font-size: 22rpx;
	color: #666;
}

.welcome-close {
	font-size: 28rpx;
	color: #999;
	padding: 8rpx;
}

.skeleton-cards {
	display: flex;
	gap: 12rpx;
}

.skeleton-card {
	flex: 1;
	height: 160rpx;
	background: linear-gradient(90deg, #f0f0f0 25%, #e8e8e8 50%, #f0f0f0 75%);
	background-size: 200% 100%;
	animation: shimmer 1.5s infinite;
	border-radius: 20rpx;
}

.skeleton-block {
	height: 200rpx;
	background: linear-gradient(90deg, #f0f0f0 25%, #e8e8e8 50%, #f0f0f0 75%);
	background-size: 200% 100%;
	animation: shimmer 1.5s infinite;
	border-radius: 24rpx;
	margin-top: 24rpx;

	&.tall {
		height: 340rpx;
	}
}

@keyframes shimmer {
	0% { background-position: 200% 0; }
	100% { background-position: -200% 0; }
}
</style>
