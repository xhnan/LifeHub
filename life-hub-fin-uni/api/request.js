import { BASE_URL, TIMEOUT } from './config.js'
import { getToken } from '../utils/auth.js'

function request(options) {
	return new Promise((resolve, reject) => {
		const token = getToken()
		const header = {
			'Content-Type': 'application/json',
			...(options.header || {})
		}
		// 除登录接口外，其他都需要 Authorization
		if (token && !options.noAuth) {
			header['Authorization'] = 'Bearer ' + token
		}

		uni.request({
			url: BASE_URL + options.url,
			method: options.method || 'GET',
			data: options.data,
			header,
			timeout: TIMEOUT,
			success: (res) => {
				const body = res.data
				// 统一响应格式 { code, message, data, timestamp, success }
				if (res.statusCode === 200 && body && body.success) {
					resolve(body.data)
				} else if (res.statusCode === 401 || (body && body.code === 401)) {
					const { logout } = require('../utils/auth.js')
					uni.showToast({ title: '登录已过期', icon: 'none' })
					setTimeout(() => logout(), 500)
					reject(new Error('未授权，请重新登录'))
				} else {
					const msg = (body && body.message) || `请求失败 (${res.statusCode})`
					reject(new Error(msg))
				}
			},
			fail: (err) => {
				reject(new Error(err.errMsg || '网络异常'))
			}
		})
	})
}

export function get(url, data) {
	return request({ url, method: 'GET', data })
}

export function post(url, data, noAuth = false) {
	return request({ url, method: 'POST', data, noAuth })
}

export function put(url, data) {
	return request({ url, method: 'PUT', data })
}

export function del(url, data) {
	return request({ url, method: 'DELETE', data })
}

export default request
