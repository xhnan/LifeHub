<template>
	<view class="records-page">
		<!-- 搜索栏 -->
		<view class="search-bar">
			<view class="search-input-wrap">
				<text class="search-icon">🔍</text>
				<input
					class="search-input"
					type="text"
					placeholder="搜索备注关键词..."
					v-model="keyword"
					@input="onSearch"
					confirm-type="search"
				/>
				<text class="search-clear" v-if="keyword" @click="clearSearch">✕</text>
			</view>
		</view>

		<!-- 筛选栏 -->
		<view class="section">
			<FilterBar
				:accountNames="accountNameList"
				:categories="categoryData"
				@change="onFilterChange"
			/>
		</view>

		<!-- 记录列表 -->
		<view class="section">
			<view class="record-groups" v-if="groupedRecords.length > 0">
				<view class="date-group" v-for="group in groupedRecords" :key="group.date">
					<view class="date-header">
						<text class="date-text">{{ group.displayDate }}</text>
						<view class="date-totals">
							<text class="date-income money-font" v-if="group.income > 0">+{{ formatMoney(group.income) }}</text>
							<text class="date-expense money-font" v-if="group.expense > 0">-{{ formatMoney(group.expense) }}</text>
						</view>
					</view>
					<view class="date-records">
						<RecordItem v-for="record in group.records" :key="record.id" :record="record" />
					</view>
				</view>
			</view>
			<view class="empty-state" v-else>
				<text class="empty-icon">📭</text>
				<text class="empty-text">没有找到匹配的记录</text>
			</view>
		</view>

		<view style="height: 40rpx;"></view>
	</view>
</template>

<script>
import FilterBar from '../../components/FilterBar/FilterBar.vue'
import RecordItem from '../../components/RecordItem/RecordItem.vue'
import { getRecords, getCategories } from '../../api/index.js'
import { records as mockRecords, accounts as mockAccounts, categories as mockCategories } from '../../mock/data.js'

export default {
	components: { FilterBar, RecordItem },
	data() {
		return {
			keyword: '',
			filters: {},
			allRecords: [],
			accountNameList: [],
			categoryData: { income: [], expense: [] }
		}
	},
	onShow() {
		this.loadData()
	},
	computed: {
		filteredRecords() {
			let result = [...this.allRecords]
			if (this.keyword) {
				const kw = this.keyword.toLowerCase()
				result = result.filter(r =>
					(r.note && r.note.toLowerCase().includes(kw)) || r.category.toLowerCase().includes(kw)
				)
			}
			if (this.filters.startDate) result = result.filter(r => r.date >= this.filters.startDate)
			if (this.filters.endDate) result = result.filter(r => r.date <= this.filters.endDate)
			if (this.filters.account) result = result.filter(r => r.account === this.filters.account)
			if (this.filters.category) result = result.filter(r => r.category === this.filters.category)
			if (this.filters.minAmount) {
				const min = parseFloat(this.filters.minAmount)
				if (!isNaN(min)) result = result.filter(r => r.amount >= min)
			}
			if (this.filters.maxAmount) {
				const max = parseFloat(this.filters.maxAmount)
				if (!isNaN(max)) result = result.filter(r => r.amount <= max)
			}
			return result
		},
		groupedRecords() {
			const groups = {}
			this.filteredRecords.forEach(record => {
				if (!groups[record.date]) groups[record.date] = []
				groups[record.date].push(record)
			})
			return Object.keys(groups).sort((a, b) => b.localeCompare(a)).map(date => {
				const records = groups[date]
				return {
					date,
					displayDate: this.formatDisplayDate(date),
					records,
					income: records.filter(r => r.type === 'income').reduce((s, r) => s + r.amount, 0),
					expense: records.filter(r => r.type === 'expense').reduce((s, r) => s + r.amount, 0)
				}
			})
		}
	},
	methods: {
		async loadData() {
			const [recordsRes, categoriesRes] = await Promise.allSettled([
				getRecords({ page: 1, pageSize: 100 }),
				getCategories()
			])

			this.allRecords = recordsRes.status === 'fulfilled'
				? (recordsRes.value.records || recordsRes.value)
				: mockRecords

			if (categoriesRes.status === 'fulfilled') {
				this.categoryData = categoriesRes.value
			} else {
				this.categoryData = mockCategories
			}

			// 从记录中提取账户名列表
			this.accountNameList = [...new Set(this.allRecords.map(r => r.account))]
			if (this.accountNameList.length === 0) {
				this.accountNameList = mockAccounts.map(a => a.name)
			}
		},
		onSearch() {},
		clearSearch() { this.keyword = '' },
		onFilterChange(filters) { this.filters = filters },
		formatDisplayDate(dateStr) {
			const d = new Date(dateStr)
			const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
			const today = new Date()
			const todayStr = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`
			if (dateStr === todayStr) return '今天'
			const yesterday = new Date(today)
			yesterday.setDate(yesterday.getDate() - 1)
			const yesterdayStr = `${yesterday.getFullYear()}-${String(yesterday.getMonth() + 1).padStart(2, '0')}-${String(yesterday.getDate()).padStart(2, '0')}`
			if (dateStr === yesterdayStr) return '昨天'
			return `${d.getMonth() + 1}月${d.getDate()}日 ${weekDays[d.getDay()]}`
		},
		formatMoney(val) {
			return '¥' + val.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
		}
	}
}
</script>

<style lang="scss" scoped>
.records-page {
	padding: 24rpx;
}

.search-bar {
	margin-bottom: 20rpx;
}

.search-input-wrap {
	display: flex;
	align-items: center;
	background: #ffffff;
	border-radius: 24rpx;
	padding: 16rpx 24rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.search-icon {
	font-size: 28rpx;
	margin-right: 12rpx;
	flex-shrink: 0;
}

.search-input {
	flex: 1;
	font-size: 28rpx;
	color: #333;
}

.search-clear {
	font-size: 28rpx;
	color: #999;
	padding: 4rpx 8rpx;
	flex-shrink: 0;
}

.section {
	margin-bottom: 24rpx;
}

.date-group {
	background: #ffffff;
	border-radius: 24rpx;
	padding: 24rpx 28rpx;
	margin-bottom: 20rpx;
	box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
}

.date-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 12rpx;
	padding-bottom: 16rpx;
	border-bottom: 1rpx solid #f5f5f5;
}

.date-text {
	font-size: 26rpx;
	font-weight: 600;
	color: #1a1a1a;
}

.date-totals {
	display: flex;
	gap: 16rpx;
}

.date-income { font-size: 24rpx; color: #059669; }
.date-expense { font-size: 24rpx; color: #ef4444; }

.empty-state {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	padding: 80rpx 0;
}

.empty-icon { font-size: 60rpx; margin-bottom: 16rpx; }
.empty-text { font-size: 28rpx; color: #ccc; }
</style>
