<script>
	import { isLoggedIn } from './utils/auth.js'

	// 不需要登录的页面白名单
	const whiteList = ['/pages/login/login']

	export default {
		onLaunch: function() {
			console.log('App Launch')
		},
		onShow: function() {
			console.log('App Show')
		},
		onHide: function() {
			console.log('App Hide')
		}
	}

	// 全局登录拦截
	const originalNavigateTo = uni.navigateTo
	const originalRedirectTo = uni.redirectTo
	const originalReLaunch = uni.reLaunch
	const originalSwitchTab = uni.switchTab

	function checkLogin(url) {
		if (!url) return true
		// 提取路径部分
		const path = url.split('?')[0]
		if (whiteList.includes(path)) return true
		if (isLoggedIn()) return true
		// 未登录，跳转到登录页
		uni.reLaunch({ url: '/pages/login/login' })
		return false
	}

	// 拦截路由跳转
	uni.navigateTo = function(options) {
		if (checkLogin(options.url)) {
			originalNavigateTo(options)
		}
	}
	uni.redirectTo = function(options) {
		if (checkLogin(options.url)) {
			originalRedirectTo(options)
		}
	}
	uni.reLaunch = function(options) {
		if (checkLogin(options.url)) {
			originalReLaunch(options)
		}
	}
	uni.switchTab = function(options) {
		if (checkLogin(options.url)) {
			originalSwitchTab(options)
		}
	}
</script>

<style lang="scss">
	/* 全局公共样式 */
	page {
		background: linear-gradient(180deg, #f0fdf4 0%, #ecfdf5 50%, #f0fdfa 100%);
		min-height: 100vh;
		font-family: -apple-system, BlinkMacSystemFont, 'Helvetica Neue', sans-serif;
		color: #1a1a1a;
	}

	/* 金额字体 */
	.money-font {
		font-family: 'Georgia', 'DIN Alternate', 'Times New Roman', serif;
		font-variant-numeric: tabular-nums;
	}

	/* 收入色 */
	.income-color {
		color: #059669;
	}

	/* 支出色 */
	.expense-color {
		color: #ef4444;
	}

	/* 安全区域底部 padding */
	.safe-bottom {
		padding-bottom: env(safe-area-inset-bottom);
	}
</style>
