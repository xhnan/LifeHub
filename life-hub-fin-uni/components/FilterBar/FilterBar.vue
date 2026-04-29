<template>
	<view class="filter-bar">
		<view class="filter-toggle" @click="expanded = !expanded">
			<text class="filter-toggle-text">筛选条件</text>
			<text class="filter-toggle-arrow">{{ expanded ? '▲' : '▼' }}</text>
		</view>

		<view class="filter-content" v-if="expanded">
			<!-- 时间范围 -->
			<view class="filter-row">
				<text class="filter-label">时间</text>
				<view class="filter-date-range">
					<picker mode="date" :value="filters.startDate" @change="onStartDateChange">
						<view class="date-picker">
							{{ filters.startDate || '开始日期' }}
						</view>
					</picker>
					<text class="date-sep">~</text>
					<picker mode="date" :value="filters.endDate" @change="onEndDateChange">
						<view class="date-picker">
							{{ filters.endDate || '结束日期' }}
						</view>
					</picker>
				</view>
			</view>

			<!-- 账户 -->
			<view class="filter-row">
				<text class="filter-label">账户</text>
				<picker :range="accountNames" @change="onAccountChange">
					<view class="filter-select">
						{{ filters.account || '全部账户' }}
					</view>
				</picker>
			</view>

			<!-- 分类 -->
			<view class="filter-row">
				<text class="filter-label">分类</text>
				<picker :range="allCategories" @change="onCategoryChange">
					<view class="filter-select">
						{{ filters.category || '全部分类' }}
					</view>
				</picker>
			</view>

			<!-- 金额范围 -->
			<view class="filter-row">
				<text class="filter-label">金额</text>
				<view class="filter-amount-range">
					<input
						class="amount-input"
						type="digit"
						placeholder="最低"
						v-model="filters.minAmount"
						@input="emitFilters"
					/>
					<text class="date-sep">~</text>
					<input
						class="amount-input"
						type="digit"
						placeholder="最高"
						v-model="filters.maxAmount"
						@input="emitFilters"
					/>
				</view>
			</view>

			<!-- 重置 -->
			<view class="filter-actions">
				<view class="filter-reset" @click="resetFilters">
					重置筛选
				</view>
			</view>
		</view>
	</view>
</template>

<script>
export default {
	name: 'FilterBar',
	props: {
		accountNames: { type: Array, default: () => [] },
		categories: { type: Object, default: () => ({ income: [], expense: [] }) }
	},
	emits: ['change'],
	data() {
		return {
			expanded: false,
			filters: {
				startDate: '',
				endDate: '',
				account: '',
				category: '',
				minAmount: '',
				maxAmount: ''
			}
		}
	},
	computed: {
		allCategories() {
			return [...this.categories.income, ...this.categories.expense]
		}
	},
	methods: {
		onStartDateChange(e) {
			this.filters.startDate = e.detail.value
			this.emitFilters()
		},
		onEndDateChange(e) {
			this.filters.endDate = e.detail.value
			this.emitFilters()
		},
		onAccountChange(e) {
			this.filters.account = this.accountNames[e.detail.value]
			this.emitFilters()
		},
		onCategoryChange(e) {
			this.filters.category = this.allCategories[e.detail.value]
			this.emitFilters()
		},
		resetFilters() {
			this.filters = {
				startDate: '',
				endDate: '',
				account: '',
				category: '',
				minAmount: '',
				maxAmount: ''
			}
			this.emitFilters()
		},
		emitFilters() {
			this.$emit('change', { ...this.filters })
		}
	}
}
</script>

<style lang="scss" scoped>
.filter-bar {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 24rpx 28rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.filter-toggle {
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.filter-toggle-text {
	font-size: 28rpx;
	font-weight: 600;
	color: #1a1a1a;
}

.filter-toggle-arrow {
	font-size: 22rpx;
	color: #999;
}

.filter-content {
	margin-top: 24rpx;
	padding-top: 24rpx;
	border-top: 1rpx solid #f0f0f0;
}

.filter-row {
	display: flex;
	align-items: center;
	margin-bottom: 20rpx;

	&:last-of-type {
		margin-bottom: 16rpx;
	}
}

.filter-label {
	font-size: 26rpx;
	color: #666;
	width: 80rpx;
	flex-shrink: 0;
}

.filter-date-range,
.filter-amount-range {
	flex: 1;
	display: flex;
	align-items: center;
	gap: 12rpx;
}

.date-sep {
	color: #ccc;
	font-size: 24rpx;
}

.date-picker,
.filter-select {
	flex: 1;
	padding: 14rpx 20rpx;
	background: #f8f9fa;
	border-radius: 12rpx;
	font-size: 24rpx;
	color: #333;
	text-align: center;
}

.amount-input {
	flex: 1;
	padding: 14rpx 20rpx;
	background: #f8f9fa;
	border-radius: 12rpx;
	font-size: 24rpx;
	color: #333;
	text-align: center;
}

.filter-actions {
	display: flex;
	justify-content: flex-end;
}

.filter-reset {
	font-size: 26rpx;
	color: #059669;
	padding: 10rpx 24rpx;
	border: 1rpx solid #059669;
	border-radius: 24rpx;
}
</style>
