<template>
	<view class="profile-page">
		<!-- 用户信息卡片 -->
		<view class="profile-card">
			<view class="card-bg"></view>
			<view class="profile-content">
				<view class="profile-avatar">{{ user.avatar || '🧑' }}</view>
				<view class="profile-info">
					<text class="profile-name">{{ user.nickname || user.username || '用户' }}</text>
					<text class="profile-join">记账 {{ daysCount }} 天</text>
				</view>
			</view>
			<!-- 快速统计 -->
			<view class="profile-stats">
				<view class="stat-item">
					<text class="stat-value money-font">{{ totalRecords }}</text>
					<text class="stat-label">总记录</text>
				</view>
				<view class="stat-divider"></view>
				<view class="stat-item">
					<text class="stat-value money-font">{{ monthExpense }}</text>
					<text class="stat-label">本月支出</text>
				</view>
				<view class="stat-divider"></view>
				<view class="stat-item">
					<text class="stat-value money-font">{{ accountCount }}</text>
					<text class="stat-label">账户数</text>
				</view>
			</view>
		</view>

		<!-- 功能列表 -->
		<view class="func-card">
			<view class="func-item pressable" @click="goMonthlyReport">
				<view class="func-icon-wrap" style="background: rgba(99, 102, 241, 0.1);">
					<text class="func-icon">📊</text>
				</view>
				<text class="func-text">月度报告</text>
				<text class="func-arrow">›</text>
			</view>
			<view class="func-item pressable" @click="goSettings">
				<view class="func-icon-wrap" style="background: rgba(245, 158, 11, 0.1);">
					<text class="func-icon">⚙️</text>
				</view>
				<text class="func-text">设置</text>
				<view class="func-badge" v-if="!hasBudget">
					<text class="badge-text">设置预算</text>
				</view>
				<text class="func-arrow">›</text>
			</view>
			<view class="func-item pressable" @click="goFeedback">
				<view class="func-icon-wrap" style="background: rgba(14, 165, 233, 0.1);">
					<text class="func-icon">💬</text>
				</view>
				<text class="func-text">意见反馈</text>
				<text class="func-arrow">›</text>
			</view>
			<view class="func-item pressable" @click="goAbout">
				<view class="func-icon-wrap" style="background: rgba(16, 185, 129, 0.1);">
					<text class="func-icon">ℹ️</text>
				</view>
				<text class="func-text">关于</text>
				<text class="func-arrow">›</text>
			</view>
		</view>

		<!-- 退出登录 -->
		<view class="logout-btn pressable" @click="handleLogout">
			<text class="logout-text">退出登录</text>
		</view>

		<view style="height: 40rpx;"></view>
	</view>
</template>

<script>
import { getUser, logout } from '../../utils/auth.js'
import { records as mockRecords, accounts as mockAccounts } from '../../mock/data.js'

export default {
	data() {
		return {
			hasBudget: false
		}
	},
	computed: {
		user() {
			return getUser() || {}
		},
		totalRecords() {
			return mockRecords.length
		},
		monthExpense() {
			const now = new Date()
			const total = mockRecords
				.filter(r => {
					if (r.type !== 'expense') return false
					const d = new Date(r.date)
					return d.getFullYear() === now.getFullYear() && d.getMonth() === now.getMonth()
				})
				.reduce((s, r) => s + r.amount, 0)
			if (total >= 10000) return (total / 10000).toFixed(1) + '万'
			return '¥' + total.toFixed(0)
		},
		accountCount() {
			return mockAccounts.length
		},
		daysCount() {
			const dates = new Set(mockRecords.map(r => r.date))
			return dates.size
		}
	},
	onShow() {
		this.checkBudget()
	},
	methods: {
		checkBudget() {
			try {
				const settings = uni.getStorageSync('lifehub_settings')
				if (settings) {
					const parsed = JSON.parse(settings)
					this.hasBudget = !!parsed.monthlyBudget
				}
			} catch (e) {}
		},
		goMonthlyReport() {
			const now = new Date()
			uni.navigateTo({
				url: `/pages/monthly-report/monthly-report?year=${now.getFullYear()}&month=${now.getMonth() + 1}`
			})
		},
		goSettings() {
			uni.navigateTo({ url: '/pages/settings/settings' })
		},
		goFeedback() {
			uni.showModal({
				title: '意见反馈',
				content: '如有建议或问题，请发送邮件至 support@lifehub.app',
				showCancel: false,
				confirmText: '我知道了'
			})
		},
		goAbout() {
			uni.navigateTo({ url: '/pages/about/about' })
		},
		handleLogout() {
			uni.showModal({
				title: '确认退出',
				content: '确定要退出登录吗？',
				confirmColor: '#ef4444',
				success: (res) => {
					if (res.confirm) {
						logout()
					}
				}
			})
		}
	}
}
</script>

<style lang="scss" scoped>
.profile-page {
	padding: 24rpx;
}

.profile-card {
	background: #ffffff;
	border-radius: 28rpx;
	overflow: hidden;
	position: relative;
	box-shadow: 0 4rpx 24rpx rgba(0, 0, 0, 0.06);
}

.card-bg {
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	height: 200rpx;
	background: linear-gradient(135deg, #059669, #10b981, #34d399);
}

.profile-content {
	position: relative;
	display: flex;
	align-items: center;
	gap: 20rpx;
	padding: 36rpx 32rpx 28rpx;
}

.profile-avatar {
	width: 96rpx;
	height: 96rpx;
	border-radius: 50%;
	background: rgba(255, 255, 255, 0.25);
	border: 4rpx solid rgba(255, 255, 255, 0.4);
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 44rpx;
}

.profile-info {
	display: flex;
	flex-direction: column;
	gap: 4rpx;
}

.profile-name {
	font-size: 34rpx;
	font-weight: 700;
	color: #ffffff;
}

.profile-join {
	font-size: 22rpx;
	color: rgba(255, 255, 255, 0.75);
}

.profile-stats {
	display: flex;
	align-items: center;
	padding: 28rpx 32rpx;
}

.stat-item {
	flex: 1;
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 4rpx;
}

.stat-value {
	font-size: 30rpx;
	font-weight: 700;
	color: #1a1a1a;
}

.stat-label {
	font-size: 22rpx;
	color: #999;
}

.stat-divider {
	width: 1rpx;
	height: 48rpx;
	background: #f0f0f0;
}

.func-card {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 8rpx 28rpx;
	margin-top: 24rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.func-item {
	display: flex;
	align-items: center;
	padding: 28rpx 0;

	& + .func-item {
		border-top: 1rpx solid #f5f5f5;
	}
}

.func-icon-wrap {
	width: 64rpx;
	height: 64rpx;
	border-radius: 16rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	margin-right: 20rpx;
}

.func-icon {
	font-size: 28rpx;
}

.func-text {
	flex: 1;
	font-size: 28rpx;
	color: #333;
	font-weight: 500;
}

.func-badge {
	padding: 4rpx 12rpx;
	background: rgba(245, 158, 11, 0.1);
	border-radius: 8rpx;
	margin-right: 12rpx;
}

.badge-text {
	font-size: 20rpx;
	color: #f59e0b;
	font-weight: 500;
}

.func-arrow {
	font-size: 32rpx;
	color: #ccc;
}

.logout-btn {
	margin-top: 40rpx;
	background: #ffffff;
	border-radius: 20rpx;
	padding: 28rpx;
	text-align: center;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
	border: 1rpx solid rgba(239, 68, 68, 0.1);
}

.logout-text {
	font-size: 30rpx;
	color: #ef4444;
	font-weight: 500;
}
</style>
