<template>
	<view class="about-page">
		<view class="about-header">
			<view class="app-icon">💰</view>
			<text class="app-title">LifeHub 财务</text>
			<text class="app-version">v1.0.0</text>
			<text class="app-slogan">你的智能财务助手</text>
		</view>

		<view class="about-card">
			<view class="info-item">
				<text class="info-label">产品简介</text>
				<text class="info-desc">LifeHub 财务是一款轻量级个人记账工具，帮助你清晰掌控日常收支、资产状况和财务健康。</text>
			</view>
		</view>

		<view class="about-card">
			<view class="info-item">
				<text class="info-label">核心功能</text>
			</view>
			<view class="feature-list">
				<view class="feature-item" v-for="feature in features" :key="feature.title">
					<text class="feature-icon">{{ feature.icon }}</text>
					<view class="feature-info">
						<text class="feature-title">{{ feature.title }}</text>
						<text class="feature-desc">{{ feature.desc }}</text>
					</view>
				</view>
			</view>
		</view>

		<view class="about-card">
			<view class="info-item">
				<text class="info-label">技术栈</text>
				<text class="info-desc">uni-app + Vue 3 · 跨平台（微信小程序 / H5 / App）</text>
			</view>
		</view>

		<view class="about-footer">
			<text class="footer-text">© 2025 LifeHub Team</text>
		</view>
	</view>
</template>

<script>
export default {
	data() {
		return {
			features: [
				{ icon: '📊', title: '资产总览', desc: '一眼掌握总资产、负债和净资产' },
				{ icon: '📝', title: '快速记账', desc: '支出/收入一键记录，分类管理' },
				{ icon: '📅', title: '日历视图', desc: '按日查看收支，直观清晰' },
				{ icon: '📈', title: '月度报告', desc: '趋势图表，财务健康评分' },
				{ icon: '🔍', title: '智能筛选', desc: '按时间、账户、分类、金额快速检索' }
			]
		}
	}
}
</script>

<style lang="scss" scoped>
.about-page {
	padding: 24rpx;
}

.about-header {
	display: flex;
	flex-direction: column;
	align-items: center;
	padding: 60rpx 0 40rpx;
}

.app-icon {
	font-size: 80rpx;
	margin-bottom: 20rpx;
}

.app-title {
	font-size: 40rpx;
	font-weight: 700;
	color: #1a1a1a;
	margin-bottom: 8rpx;
}

.app-version {
	font-size: 24rpx;
	color: #999;
	margin-bottom: 12rpx;
}

.app-slogan {
	font-size: 26rpx;
	color: #059669;
	font-weight: 500;
}

.about-card {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 28rpx;
	margin-bottom: 24rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.info-item {
	margin-bottom: 12rpx;
}

.info-label {
	font-size: 28rpx;
	font-weight: 600;
	color: #1a1a1a;
	display: block;
	margin-bottom: 12rpx;
}

.info-desc {
	font-size: 26rpx;
	color: #666;
	line-height: 1.6;
}

.feature-list {
	display: flex;
	flex-direction: column;
	gap: 20rpx;
}

.feature-item {
	display: flex;
	align-items: flex-start;
	gap: 16rpx;
}

.feature-icon {
	font-size: 32rpx;
	flex-shrink: 0;
	margin-top: 4rpx;
}

.feature-info {
	display: flex;
	flex-direction: column;
	gap: 4rpx;
}

.feature-title {
	font-size: 26rpx;
	font-weight: 600;
	color: #333;
}

.feature-desc {
	font-size: 24rpx;
	color: #999;
}

.about-footer {
	text-align: center;
	padding: 40rpx 0;
}

.footer-text {
	font-size: 22rpx;
	color: #ccc;
}
</style>
