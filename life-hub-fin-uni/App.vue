<script>
	import { isLoggedIn } from './utils/auth.js'

	// 不需要登录的页面白名单
	const whiteList = ['/pages/login/login']

	export default {
		onLaunch: function() {
			console.log('App Launch')
			// 检查登录状态，未登录则跳转
			if (!isLoggedIn()) {
				uni.reLaunch({ url: '/pages/login/login' })
			}
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
		const path = url.split('?')[0]
		if (whiteList.includes(path)) return true
		if (isLoggedIn()) return true
		// 未登录，跳转到登录页
		originalReLaunch({ url: '/pages/login/login' })
		return false
	}

	// 拦截路由跳转（使用 originalReLaunch 避免递归）
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
		background: linear-gradient(180deg, #f0fdf4 0%, #ecfdf5 40%, #f8fafc 100%);
		min-height: 100vh;
		font-family: -apple-system, BlinkMacSystemFont, 'PingFang SC', 'Helvetica Neue', sans-serif;
		color: #1a1a1a;
		-webkit-font-smoothing: antialiased;
	}

	/* 金额字体 */
	.money-font {
		font-family: 'DIN Alternate', 'Georgia', 'Helvetica Neue', monospace;
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

	/* 全局卡片阴影 */
	.card-shadow {
		box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.04);
	}

	/* 全局过渡 */
	view, text {
		transition-property: background-color, color, border-color, opacity;
		transition-duration: 0.15s;
		transition-timing-function: ease-out;
	}

	/* 按压反馈 */
	.pressable {
		transition: transform 0.1s ease;

		&:active {
			transform: scale(0.97);
		}
	}

	/* 隐藏滚动条 */
	::-webkit-scrollbar {
		display: none;
		width: 0;
		height: 0;
	}

	/* Toast 自定义样式 */
	.uni-toast {
		border-radius: 16rpx !important;
	}
</style>
