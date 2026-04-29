const TOKEN_KEY = 'lifehub_token'
const USER_KEY = 'lifehub_user'

export function getToken() {
	return uni.getStorageSync(TOKEN_KEY) || ''
}

export function setToken(token) {
	uni.setStorageSync(TOKEN_KEY, token)
}

export function removeToken() {
	uni.removeStorageSync(TOKEN_KEY)
}

export function getUser() {
	const raw = uni.getStorageSync(USER_KEY)
	if (!raw) return null
	try {
		return typeof raw === 'string' ? JSON.parse(raw) : raw
	} catch {
		return null
	}
}

export function setUser(user) {
	uni.setStorageSync(USER_KEY, JSON.stringify(user))
}

export function removeUser() {
	uni.removeStorageSync(USER_KEY)
}

export function isLoggedIn() {
	return !!getToken()
}

export function logout() {
	removeToken()
	removeUser()
	uni.reLaunch({
		url: '/pages/login/login'
	})
}
