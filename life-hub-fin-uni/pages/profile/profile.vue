<template>
	<view class="profile-page">
		<!-- 用户信息卡片 -->
		<view class="profile-card">
			<view class="profile-avatar">{{ user.avatar || '🧑' }}</view>
			<view class="profile-info">
				<text class="profile-name">{{ user.nickname || user.username || '用户' }}</text>
				<text class="profile-id">ID: {{ user.id || '--' }}</text>
			</view>
		</view>

		<!-- 功能列表 -->
		<view class="func-card">
			<view class="func-item" @click="goMonthlyReport">
				<text class="func-icon">📊</text>
				<text class="func-text">月度报告</text>
				<text class="func-arrow">›</text>
			</view>
			<view class="func-item">
				<text class="func-icon">⚙️</text>
				<text class="func-text">设置</text>
				<text class="func-arrow">›</text>
			</view>
			<view class="func-item">
				<text class="func-icon">💬</text>
				<text class="func-text">意见反馈</text>
				<text class="func-arrow">›</text>
			</view>
			<view class="func-item">
				<text class="func-icon">ℹ️</text>
				<text class="func-text">关于</text>
				<text class="func-arrow">›</text>
			</view>
		</view>

		<!-- 退出登录 -->
		<view class="logout-btn" @click="handleLogout">
			<text class="logout-text">退出登录</text>
		</view>
	</view>
</template>

<script>
import { getUser, logout } from '../../utils/auth.js'

export default {
	data() {
		return {}
	},
	computed: {
		user() {
			return getUser() || {}
		}
	},
	methods: {
		goMonthlyReport() {
			const now = new Date()
			uni.navigateTo({
				url: `/pages/monthly-report/monthly-report?year=${now.getFullYear()}&month=${now.getMonth() + 1}`
			})
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
	background: linear-gradient(135deg, #059669, #10b981);
	border-radius: 24rpx;
	padding: 40rpx 32rpx;
	display: flex;
	align-items: center;
	gap: 24rpx;
	box-shadow: 0 4rpx 24rpx rgba(5, 150, 105, 0.3);
}

.profile-avatar {
	width: 100rpx;
	height: 100rpx;
	border-radius: 50%;
	background: rgba(255, 255, 255, 0.2);
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 48rpx;
}

.profile-info {
	display: flex;
	flex-direction: column;
	gap: 6rpx;
}

.profile-name {
	font-size: 34rpx;
	font-weight: 700;
	color: #ffffff;
}

.profile-id {
	font-size: 22rpx;
	color: rgba(255, 255, 255, 0.7);
}

.func-card {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 8rpx 28rpx;
	margin-top: 28rpx;
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

.func-icon {
	font-size: 36rpx;
	margin-right: 20rpx;
}

.func-text {
	flex: 1;
	font-size: 28rpx;
	color: #333;
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
}

.logout-text {
	font-size: 30rpx;
	color: #ef4444;
	font-weight: 500;
}
</style>
