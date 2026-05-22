<template>
	<view class="add-record-page">
		<!-- 收支类型切换 -->
		<view class="type-switch">
			<view
				class="type-tab"
				:class="{ active: form.type === 'expense', 'expense-active': form.type === 'expense' }"
				@click="switchType('expense')"
			>
				<text class="tab-text">支出</text>
			</view>
			<view
				class="type-tab"
				:class="{ active: form.type === 'income', 'income-active': form.type === 'income' }"
				@click="switchType('income')"
			>
				<text class="tab-text">收入</text>
			</view>
		</view>

		<!-- 金额输入 -->
		<view class="amount-section" :class="form.type">
			<text class="amount-symbol">¥</text>
			<input
				class="amount-input money-font"
				type="digit"
				placeholder="0.00"
				v-model="form.amountStr"
				:adjust-position="true"
				focus
			/>
		</view>

		<!-- 快捷金额 -->
		<view class="quick-amounts">
			<view
				class="quick-btn"
				v-for="amount in quickAmounts"
				:key="amount"
				@click="setQuickAmount(amount)"
				:class="{ selected: form.amountStr === String(amount) }"
			>
				<text class="quick-text">¥{{ amount }}</text>
			</view>
		</view>

		<!-- 分类选择 -->
		<view class="category-section">
			<text class="section-title">选择分类</text>
			<view class="category-grid">
				<view
					class="category-item"
					v-for="cat in currentCategories"
					:key="cat.name"
					:class="{ selected: form.category === cat.name }"
					@click="selectCategory(cat)"
				>
					<view class="category-icon-wrap" :class="{ selected: form.category === cat.name, [form.type]: form.category === cat.name }">
						<text class="category-icon">{{ cat.emoji }}</text>
					</view>
					<text class="category-name" :class="{ selected: form.category === cat.name }">{{ cat.name }}</text>
				</view>
			</view>
		</view>

		<!-- 详细信息 -->
		<view class="detail-section">
			<!-- 备注 -->
			<view class="detail-row">
				<text class="detail-icon">📝</text>
				<text class="detail-label">备注</text>
				<input
					class="detail-input"
					type="text"
					placeholder="添加备注..."
					v-model="form.note"
					maxlength="50"
				/>
			</view>

			<!-- 账户 -->
			<view class="detail-row">
				<text class="detail-icon">💳</text>
				<text class="detail-label">账户</text>
				<picker :range="accountNames" @change="onAccountChange">
					<view class="detail-picker">
						<text class="picker-text">{{ form.account || '选择账户' }}</text>
						<text class="picker-arrow">›</text>
					</view>
				</picker>
			</view>

			<!-- 日期 -->
			<view class="detail-row">
				<text class="detail-icon">📅</text>
				<text class="detail-label">日期</text>
				<picker mode="date" :value="form.date" @change="onDateChange">
					<view class="detail-picker">
						<text class="picker-text" :class="{ today: isToday }">{{ dateDisplay }}</text>
						<text class="picker-arrow">›</text>
					</view>
				</picker>
			</view>
		</view>

		<!-- 继续记账选项 -->
		<view class="continue-option" @click="continueAdding = !continueAdding">
			<view class="check-box" :class="{ checked: continueAdding }">
				<text class="check-icon" v-if="continueAdding">✓</text>
			</view>
			<text class="continue-text">保存后继续记账</text>
		</view>

		<!-- 提交按钮 -->
		<view class="submit-section">
			<view
				class="submit-btn"
				:class="{ disabled: !canSubmit || submitting, [form.type]: true }"
				@click="handleSubmit"
			>
				<text class="submit-text">{{ submitBtnText }}</text>
			</view>
		</view>
	</view>
</template>

<script>
import { addRecord } from '../../api/index.js'
import { accounts as mockAccounts } from '../../mock/data.js'
import { formatDate } from '../../utils/format.js'

const expenseCategories = [
	{ name: '餐饮', icon: 'mdi:food', emoji: '🍜' },
	{ name: '交通', icon: 'mdi:car', emoji: '🚗' },
	{ name: '购物', icon: 'mdi:cart', emoji: '🛒' },
	{ name: '住房', icon: 'mdi:home', emoji: '🏠' },
	{ name: '娱乐', icon: 'mdi:gamepad-variant', emoji: '🎮' },
	{ name: '医疗', icon: 'mdi:hospital-box', emoji: '🏥' },
	{ name: '教育', icon: 'mdi:school', emoji: '📚' },
	{ name: '通讯', icon: 'mdi:cellphone-wireless', emoji: '📱' },
	{ name: '日用品', icon: 'mdi:spray-bottle', emoji: '🧴' },
	{ name: '其他支出', icon: 'mdi:dots-horizontal', emoji: '💰' }
]

const incomeCategories = [
	{ name: '工资', icon: 'mdi:briefcase', emoji: '💼' },
	{ name: '奖金', icon: 'mdi:gift', emoji: '🎁' },
	{ name: '理财收益', icon: 'mdi:chart-areaspline', emoji: '📈' },
	{ name: '转账收入', icon: 'mdi:swap-horizontal', emoji: '🔄' },
	{ name: '退款', icon: 'mdi:keyboard-return', emoji: '↩️' },
	{ name: '其他收入', icon: 'mdi:cash', emoji: '💰' }
]

export default {
	data() {
		return {
			form: {
				type: 'expense',
				amountStr: '',
				category: '',
				icon: '',
				note: '',
				account: '',
				date: formatDate(new Date())
			},
			submitting: false,
			continueAdding: false,
			accountNames: [],
			savedCount: 0
		}
	},
	computed: {
		currentCategories() {
			return this.form.type === 'expense' ? expenseCategories : incomeCategories
		},
		quickAmounts() {
			return this.form.type === 'expense'
				? [10, 20, 50, 100, 200, 500]
				: [100, 500, 1000, 5000, 10000, 20000]
		},
		canSubmit() {
			return this.form.amountStr && parseFloat(this.form.amountStr) > 0 && this.form.category
		},
		isToday() {
			return this.form.date === formatDate(new Date())
		},
		dateDisplay() {
			if (this.isToday) return '今天'
			const yesterday = new Date()
			yesterday.setDate(yesterday.getDate() - 1)
			if (this.form.date === formatDate(yesterday)) return '昨天'
			return this.form.date
		},
		submitBtnText() {
			if (this.submitting) return '保存中...'
			if (this.savedCount > 0) return `继续保存 (已记${this.savedCount}笔)`
			return '保存记录'
		}
	},
	onLoad(options) {
		if (options && options.type) {
			this.form.type = options.type
		}
		this.loadAccounts()
	},
	methods: {
		loadAccounts() {
			this.accountNames = mockAccounts
				.filter(a => a.balance >= 0 || a.type === 'credit')
				.map(a => a.name)
			if (this.accountNames.length > 0) {
				this.form.account = this.accountNames[0]
			}
		},
		switchType(type) {
			this.form.type = type
			this.form.category = ''
			this.form.icon = ''
		},
		selectCategory(cat) {
			this.form.category = cat.name
			this.form.icon = cat.icon
		},
		setQuickAmount(amount) {
			this.form.amountStr = String(amount)
		},
		onAccountChange(e) {
			this.form.account = this.accountNames[e.detail.value]
		},
		onDateChange(e) {
			this.form.date = e.detail.value
		},
		async handleSubmit() {
			if (!this.canSubmit || this.submitting) return

			const amount = parseFloat(this.form.amountStr)
			if (isNaN(amount) || amount <= 0) {
				return uni.showToast({ title: '请输入有效金额', icon: 'none' })
			}
			if (!this.form.category) {
				return uni.showToast({ title: '请选择分类', icon: 'none' })
			}

			this.submitting = true
			try {
				await addRecord({
					type: this.form.type,
					amount,
					category: this.form.category,
					icon: this.form.icon,
					note: this.form.note,
					account: this.form.account,
					date: this.form.date
				})
				this.onSaveSuccess()
			} catch (e) {
				// 离线模式：保存到本地
				this.saveLocal({
					id: 'local_' + Date.now(),
					type: this.form.type,
					amount,
					category: this.form.category,
					icon: this.form.icon,
					note: this.form.note,
					account: this.form.account,
					date: this.form.date,
					timestamp: new Date(this.form.date).getTime()
				})
				this.onSaveSuccess()
			} finally {
				this.submitting = false
			}
		},
		onSaveSuccess() {
			this.savedCount++

			// 振动反馈
			// #ifdef APP-PLUS
			uni.vibrateShort()
			// #endif

			if (this.continueAdding) {
				uni.showToast({ title: '已保存 ✓', icon: 'none', duration: 1000 })
				// 重置金额和备注，保留分类和账户
				this.form.amountStr = ''
				this.form.note = ''
			} else {
				uni.showToast({ title: '保存成功', icon: 'success' })
				setTimeout(() => {
					uni.navigateBack()
				}, 800)
			}
		},
		saveLocal(record) {
			const key = 'lifehub_local_records'
			let records = []
			try {
				const raw = uni.getStorageSync(key)
				if (raw) records = JSON.parse(raw)
			} catch (e) {}
			records.unshift(record)
			uni.setStorageSync(key, JSON.stringify(records))
		}
	}
}
</script>

<style lang="scss" scoped>
.add-record-page {
	min-height: 100vh;
	padding: 24rpx;
	background: linear-gradient(180deg, #f8fafb 0%, #ffffff 100%);
}

.type-switch {
	display: flex;
	background: #ffffff;
	border-radius: 20rpx;
	padding: 6rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.type-tab {
	flex: 1;
	height: 80rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	border-radius: 16rpx;
	transition: all 0.25s;

	&.expense-active {
		background: linear-gradient(135deg, #ef4444, #f87171);
		box-shadow: 0 4rpx 16rpx rgba(239, 68, 68, 0.3);
	}

	&.income-active {
		background: linear-gradient(135deg, #059669, #10b981);
		box-shadow: 0 4rpx 16rpx rgba(5, 150, 105, 0.3);
	}
}

.tab-text {
	font-size: 30rpx;
	font-weight: 600;
	color: #999;

	.active & {
		color: #ffffff;
	}
}

.amount-section {
	display: flex;
	align-items: center;
	background: #ffffff;
	border-radius: 24rpx;
	padding: 48rpx 32rpx;
	margin-top: 24rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
	border-left: 8rpx solid #ef4444;
	transition: border-color 0.3s;

	&.income {
		border-left-color: #059669;
	}
}

.amount-symbol {
	font-size: 48rpx;
	font-weight: 700;
	color: #1a1a1a;
	margin-right: 8rpx;
}

.amount-input {
	flex: 1;
	font-size: 64rpx;
	font-weight: 700;
	color: #1a1a1a;
	height: 80rpx;
}

/* 快捷金额 */
.quick-amounts {
	display: flex;
	gap: 12rpx;
	margin-top: 16rpx;
	flex-wrap: wrap;
}

.quick-btn {
	padding: 12rpx 24rpx;
	background: #ffffff;
	border-radius: 24rpx;
	border: 2rpx solid #e5e7eb;
	transition: all 0.2s;

	&:active {
		transform: scale(0.95);
	}

	&.selected {
		border-color: #059669;
		background: rgba(5, 150, 105, 0.06);
	}
}

.quick-text {
	font-size: 24rpx;
	color: #666;
	font-weight: 500;

	.selected & {
		color: #059669;
	}
}

.category-section {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 28rpx;
	margin-top: 24rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.section-title {
	font-size: 26rpx;
	font-weight: 600;
	color: #666;
	margin-bottom: 20rpx;
	text-transform: uppercase;
	letter-spacing: 2rpx;
}

.category-grid {
	display: flex;
	flex-wrap: wrap;
	gap: 20rpx 0;
}

.category-item {
	width: 20%;
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 8rpx;
}

.category-icon-wrap {
	width: 88rpx;
	height: 88rpx;
	border-radius: 50%;
	background: #f5f5f5;
	display: flex;
	align-items: center;
	justify-content: center;
	transition: all 0.2s;

	&.selected.expense {
		background: rgba(239, 68, 68, 0.1);
		box-shadow: 0 0 0 4rpx rgba(239, 68, 68, 0.2);
	}

	&.selected.income {
		background: rgba(5, 150, 105, 0.1);
		box-shadow: 0 0 0 4rpx rgba(5, 150, 105, 0.2);
	}
}

.category-icon {
	font-size: 36rpx;
}

.category-name {
	font-size: 22rpx;
	color: #666;
	text-align: center;

	&.selected {
		color: #1a1a1a;
		font-weight: 600;
	}
}

.detail-section {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 8rpx 28rpx;
	margin-top: 24rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.detail-row {
	display: flex;
	align-items: center;
	padding: 28rpx 0;

	& + .detail-row {
		border-top: 1rpx solid #f5f5f5;
	}
}

.detail-icon {
	font-size: 24rpx;
	margin-right: 12rpx;
	flex-shrink: 0;
}

.detail-label {
	font-size: 28rpx;
	color: #666;
	width: 80rpx;
	flex-shrink: 0;
}

.detail-input {
	flex: 1;
	font-size: 28rpx;
	color: #333;
	text-align: right;
}

.detail-picker {
	flex: 1;
	display: flex;
	align-items: center;
	justify-content: flex-end;
	gap: 8rpx;
}

.picker-text {
	font-size: 28rpx;
	color: #333;

	&.today {
		color: #059669;
		font-weight: 500;
	}
}

.picker-arrow {
	font-size: 32rpx;
	color: #ccc;
}

/* 继续记账 */
.continue-option {
	display: flex;
	align-items: center;
	gap: 12rpx;
	margin-top: 24rpx;
	padding: 0 8rpx;
}

.check-box {
	width: 32rpx;
	height: 32rpx;
	border-radius: 8rpx;
	border: 2rpx solid #ddd;
	display: flex;
	align-items: center;
	justify-content: center;
	transition: all 0.2s;

	&.checked {
		background: #059669;
		border-color: #059669;
	}
}

.check-icon {
	color: #fff;
	font-size: 18rpx;
	font-weight: 700;
}

.continue-text {
	font-size: 26rpx;
	color: #999;
}

/* 提交按钮 */
.submit-section {
	margin-top: 36rpx;
	padding-bottom: 60rpx;
}

.submit-btn {
	border-radius: 20rpx;
	height: 100rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	box-shadow: 0 6rpx 24rpx rgba(5, 150, 105, 0.3);
	transition: all 0.2s;

	&.expense {
		background: linear-gradient(135deg, #ef4444, #f87171);
		box-shadow: 0 6rpx 24rpx rgba(239, 68, 68, 0.3);
	}

	&.income {
		background: linear-gradient(135deg, #059669, #10b981);
		box-shadow: 0 6rpx 24rpx rgba(5, 150, 105, 0.3);
	}

	&:active {
		transform: scale(0.98);
	}

	&.disabled {
		opacity: 0.4;
		transform: none;
	}
}

.submit-text {
	color: #ffffff;
	font-size: 32rpx;
	font-weight: 600;
	letter-spacing: 4rpx;
}
</style>
