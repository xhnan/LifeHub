import { get, post, put, del } from './request.js'

// ========== 认证 ==========

export function loginByAccount(username, password) {
	return post('/auth/login', { username, password }, true)
}

export function loginByWx(code, userInfo) {
	return post('/auth/wx-login', { code, userInfo }, true)
}

export function loginByPhone(data) {
	return post('/auth/wx-phone-login', data, true)
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

// ========== 记录增删改 ==========

export function addRecord(data) {
	return post('/app/fin/records', data)
}

export function updateRecord(id, data) {
	return put(`/app/fin/records/${id}`, data)
}

export function deleteRecord(id) {
	return del(`/app/fin/records/${id}`)
}


// ========== AI 助手 ==========

/**
 * 月度财务智能分析
 */
export function getMonthlyAiInsight(year, month, bookId) {
	const params = {}
	if (year) params.year = year
	if (month) params.month = month
	if (bookId) params.bookId = bookId
	return post('/app/fin/ai/analyze', null, false, params)
}

/**
 * 支出异常检测
 */
export function detectAnomalies(bookId) {
	return get('/app/fin/ai/anomalies', bookId ? { bookId } : {})
}

/**
 * 获取 AI 聊天的完整 URL（用于 SSE 直接连接）
 */
export function getAiChatStreamUrl() {
	const { BASE_URL } = require('./config.js')
	return BASE_URL + '/app/fin/ai/chat/stream'
}
