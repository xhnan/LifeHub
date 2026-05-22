/**
 * 共享格式化工具函数
 * 替代各组件中重复的 formatMoney / shortMoney / formatDate
 */

/**
 * 格式化金额（完整）
 * @param {number} val 金额数值
 * @param {boolean} showSign 是否显示正负号
 * @returns {string} 如 ¥12,345.67
 */
export function formatMoney(val, showSign = false) {
	if (val === undefined || val === null) return '¥0.00'
	const abs = Math.abs(val)
	const formatted = '¥' + abs.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
	if (showSign) {
		return val >= 0 ? '+' + formatted : '-' + formatted
	}
	return val < 0 ? '-' + formatted : formatted
}

/**
 * 简短金额（超过 1万 显示 x.x万，超过 1千 显示 x.xk）
 * @param {number} val
 * @returns {string}
 */
export function shortMoney(val) {
	if (val === undefined || val === null) return '¥0'
	const abs = Math.abs(val)
	if (abs >= 10000) return (val / 10000).toFixed(1) + '万'
	if (abs >= 1000) return (val / 1000).toFixed(1) + 'k'
	return '¥' + val.toFixed(0)
}

/**
 * 格式化日期为 YYYY-MM-DD
 * @param {Date|string} date
 * @returns {string}
 */
export function formatDate(date) {
	const d = date instanceof Date ? date : new Date(date)
	const y = d.getFullYear()
	const m = String(d.getMonth() + 1).padStart(2, '0')
	const day = String(d.getDate()).padStart(2, '0')
	return `${y}-${m}-${day}`
}

/**
 * 获取今天的日期字符串
 * @returns {string} YYYY-MM-DD
 */
export function getToday() {
	return formatDate(new Date())
}

/**
 * 格式化展示日期 (如 "5月20日 周三")
 * @param {string} dateStr YYYY-MM-DD
 * @returns {string}
 */
export function formatDisplayDate(dateStr) {
	const d = new Date(dateStr)
	const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
	const today = getToday()
	if (dateStr === today) return '今天'

	const yesterday = new Date()
	yesterday.setDate(yesterday.getDate() - 1)
	if (dateStr === formatDate(yesterday)) return '昨天'

	return `${d.getMonth() + 1}月${d.getDate()}日 ${weekDays[d.getDay()]}`
}

/**
 * 获取当前时间的问候语
 * @returns {string}
 */
export function getGreeting() {
	const h = new Date().getHours()
	if (h < 6) return '夜深了，注意休息'
	if (h < 9) return '早上好，新的一天'
	if (h < 12) return '上午好，加油'
	if (h < 14) return '中午好，记得吃饭'
	if (h < 18) return '下午好'
	if (h < 22) return '晚上好'
	return '夜深了，注意休息'
}
