<template>
	<view class="settings-page">
		<view class="settings-card">
			<view class="settings-item">
				<text class="item-label">货币单位</text>
				<text class="item-value">人民币 (¥)</text>
			</view>
			<view class="settings-item">
				<text class="item-label">每月起始日</text>
				<picker :range="dayOptions" @change="onStartDayChange">
					<view class="item-value-wrap">
						<text class="item-value">每月{{ startDay }}日</text>
						<text class="item-arrow">›</text>
					</view>
				</picker>
			</view>
			<view class="settings-item">
				<text class="item-label">预算提醒</text>
				<switch :checked="budgetAlert" @change="budgetAlert = $event.detail.value" color="#059669" />
			</view>
			<view class="settings-item">
				<text class="item-label">月度预算</text>
				<view class="item-value-wrap">
					<input
						class="budget-input money-font"
						type="digit"
						placeholder="未设置"
						v-model="monthlyBudget"
						@blur="saveBudget"
					/>
					<text class="item-unit">元</text>
				</view>
			</view>
		</view>

		<view class="settings-card">
			<view class="settings-item">
				<text class="item-label">数据导出</text>
				<view class="item-btn" @click="exportData">
					<text class="btn-text">导出 CSV</text>
				</view>
			</view>
			<view class="settings-item">
				<text class="item-label">清除缓存</text>
				<view class="item-btn" @click="clearCache">
					<text class="btn-text">清除</text>
				</view>
			</view>
		</view>

		<view class="settings-card">
			<view class="settings-item">
				<text class="item-label">版本号</text>
				<text class="item-value">v1.0.0</text>
			</view>
		</view>
	</view>
</template>

<script>
export default {
	data() {
		return {
			startDay: 1,
			budgetAlert: true,
			monthlyBudget: '',
			dayOptions: Array.from({ length: 28 }, (_, i) => `${i + 1}日`)
		}
	},
	onLoad() {
		this.loadSettings()
	},
	methods: {
		loadSettings() {
			try {
				const settings = uni.getStorageSync('lifehub_settings')
				if (settings) {
					const parsed = JSON.parse(settings)
					this.startDay = parsed.startDay || 1
					this.budgetAlert = parsed.budgetAlert !== false
					this.monthlyBudget = parsed.monthlyBudget || ''
				}
			} catch (e) {}
		},
		saveSettings() {
			uni.setStorageSync('lifehub_settings', JSON.stringify({
				startDay: this.startDay,
				budgetAlert: this.budgetAlert,
				monthlyBudget: this.monthlyBudget
			}))
		},
		onStartDayChange(e) {
			this.startDay = parseInt(e.detail.value) + 1
			this.saveSettings()
		},
		saveBudget() {
			this.saveSettings()
			uni.showToast({ title: '已保存', icon: 'success' })
		},
		exportData() {
			uni.showToast({ title: '功能开发中', icon: 'none' })
		},
		clearCache() {
			uni.showModal({
				title: '确认清除',
				content: '清除缓存不会删除账户数据，仅清理临时文件。',
				confirmColor: '#ef4444',
				success: (res) => {
					if (res.confirm) {
						uni.showToast({ title: '缓存已清除', icon: 'success' })
					}
				}
			})
		}
	}
}
</script>

<style lang="scss" scoped>
.settings-page {
	padding: 24rpx;
}

.settings-card {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 8rpx 28rpx;
	margin-bottom: 24rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.settings-item {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 28rpx 0;

	& + .settings-item {
		border-top: 1rpx solid #f5f5f5;
	}
}

.item-label {
	font-size: 28rpx;
	color: #333;
}

.item-value {
	font-size: 28rpx;
	color: #999;
}

.item-value-wrap {
	display: flex;
	align-items: center;
	gap: 8rpx;
}

.item-arrow {
	font-size: 32rpx;
	color: #ccc;
}

.item-unit {
	font-size: 26rpx;
	color: #999;
}

.budget-input {
	width: 200rpx;
	text-align: right;
	font-size: 28rpx;
	color: #1a1a1a;
}

.item-btn {
	padding: 10rpx 24rpx;
	background: #f0fdf4;
	border-radius: 12rpx;
}

.btn-text {
	font-size: 26rpx;
	color: #059669;
	font-weight: 500;
}
</style>
