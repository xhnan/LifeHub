import { get, post } from './request.js'

// ========== 认证 ==========

export function loginByAccount(username, password) {
	return post('/auth/login', { username, password }, true)
}

export function loginByWx(code) {
	return post('/auth/wx-login', { code }, true)
}

export function getProfile() {
	return get('/auth/profile')
}

// ========== 资产总览 ==========

export function getOverview(bookId) {
	return get('/app/fin/overview', bookId ? { bookId } : {})
}

export function getAccounts(bookId) {
	return get('/app/fin/accounts', bookId ? { bookId } : {})
}

export function getTrend(days = 7, bookId) {
	return get('/app/fin/trend', { days, ...(bookId ? { bookId } : {}) })
}

export function getExpenseCategories(startDate, endDate, bookId) {
	return get('/app/fin/expense-categories', {
		...(startDate ? { startDate } : {}),
		...(endDate ? { endDate } : {}),
		...(bookId ? { bookId } : {})
	})
}

// ========== 收支明细 ==========

export function getRecords(params = {}) {
	return get('/app/fin/records', params)
}

export function getCategories(bookId) {
	return get('/app/fin/categories', bookId ? { bookId } : {})
}

// ========== 日历视图 ==========

export function getCalendarSummary(year, month, bookId) {
	return get('/app/fin/calendar-summary', { year, month, ...(bookId ? { bookId } : {}) })
}

// ========== 月度报表 ==========

export function getMonthlySummary(year, month, bookId) {
	return get('/app/fin/monthly-summary', { year, month, ...(bookId ? { bookId } : {}) })
}

export function getMonthlyRank(year, month, type, bookId) {
	return get('/app/fin/monthly-rank', { year, month, type, ...(bookId ? { bookId } : {}) })
}

// ========== 月度综合报告 ==========

export function getMonthlyReport(year, month, bookId) {
	return get('/app/fin/monthly-report', { year, month, ...(bookId ? { bookId } : {}) })
}
