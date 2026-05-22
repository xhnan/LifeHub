<template>
	<view class="login-page">
		<!-- 顶部装饰 -->
		<view class="login-header">
			<view class="header-circle c1"></view>
			<view class="header-circle c2"></view>
			<view class="header-circle c3"></view>
			<view class="logo-wrap">
				<text class="logo-icon">💰</text>
			</view>
			<text class="app-name">LifeHub 财务</text>
			<text class="app-desc">你的智能财务助手</text>
		</view>

		<!-- 微信一键登录（小程序环境优先显示） -->
		<!-- #ifdef MP-WEIXIN -->
		<view class="login-card" v-if="mode === 'wechat'">
			<view class="wechat-section">
				<view class="wechat-avatar-wrap">
					<text class="wechat-avatar-icon">🟢</text>
				</view>
				<text class="wechat-title">微信用户，欢迎使用</text>
				<text class="wechat-desc">授权微信登录，即刻开始记账</text>

				<!-- 手机号快速登录 -->
				<button
					class="phone-login-btn"
					open-type="getPhoneNumber"
					@getphonenumber="handlePhoneLogin"
					:loading="loading"
				>
					<text class="phone-btn-icon">📱</text>
					<text class="phone-btn-text">手机号快捷登录</text>
				</button>

				<!-- 微信登录（无需手机号） -->
				<view class="wx-login-btn" @click="handleWechatLogin" :class="{ 'btn-disabled': loading }">
					<text class="wx-btn-text">{{ loading ? '登录中...' : '微信授权登录' }}</text>
				</view>
			</view>
		</view>
		<!-- #endif -->

		<!-- 账号密码登录 -->
		<view class="login-card" v-if="mode === 'account'">
			<view class="input-group">
				<view class="input-wrap" :class="{ 'input-focus': focusField === 'username' }">
					<text class="input-icon">👤</text>
					<input
						class="input-field"
						type="text"
						placeholder="请输入账号"
						v-model="form.username"
						@focus="focusField = 'username'"
						@blur="focusField = ''"
						@confirm="focusPassword"
					/>
				</view>
			</view>
			<view class="input-group">
				<view class="input-wrap" :class="{ 'input-focus': focusField === 'password' }">
					<text class="input-icon">🔒</text>
					<input
						class="input-field"
						:password="!showPassword"
						placeholder="请输入密码"
						v-model="form.password"
						@focus="focusField = 'password'"
						@blur="focusField = ''"
						@confirm="handleAccountLogin"
						:focus="passwordFocus"
					/>
					<text class="input-eye" @click="showPassword = !showPassword">
						{{ showPassword ? '👁' : '👁‍🗨' }}
					</text>
				</view>
			</view>

			<view class="form-actions">
				<view class="remember-me" @click="rememberMe = !rememberMe">
					<view class="check-box small" :class="{ checked: rememberMe }">
						<text class="check-icon" v-if="rememberMe">✓</text>
					</view>
					<text class="remember-text">记住账号</text>
				</view>
			</view>

			<view class="login-btn" @click="handleAccountLogin" :class="{ 'btn-disabled': loading || !canLogin }">
				<text class="login-btn-text">{{ loading ? '登录中...' : '登 录' }}</text>
			</view>
		</view>

		<!-- 非微信环境也显示微信入口 -->
		<!-- #ifndef MP-WEIXIN -->
		<view class="login-card" v-if="mode === 'wechat'">
			<view class="wechat-section">
				<view class="wechat-avatar-wrap">
					<text class="wechat-avatar-icon">🟢</text>
				</view>
				<text class="wechat-title">微信登录</text>
				<text class="wechat-desc">请在微信小程序中使用微信登录</text>
				<view class="wx-login-btn disabled">
					<text class="wx-btn-text">仅支持微信小程序</text>
				</view>
			</view>
		</view>
		<!-- #endif -->

		<!-- 切换登录方式 -->
		<view class="switch-mode">
			<view class="switch-divider">
				<view class="divider-line"></view>
				<text class="divider-text">或</text>
				<view class="divider-line"></view>
			</view>
			<text class="switch-text" @click="toggleMode">
				{{ mode === 'account' ? '使用微信一键登录' : '使用账号密码登录' }}
			</text>
		</view>

		<!-- 协议 -->
		<view class="agreement">
			<view class="agree-check" @click="agreed = !agreed">
				<view class="check-box" :class="{ checked: agreed }">
					<text class="check-icon" v-if="agreed">✓</text>
				</view>
				<text class="agree-text">
					我已阅读并同意
					<text class="agree-link">《用户协议》</text>
					和
					<text class="agree-link">《隐私政策》</text>
				</text>
			</view>
		</view>
	</view>
</template>

<script>
import { setToken, setUser } from '../../utils/auth.js'
import { loginByAccount, loginByWx, loginByPhone } from '../../api/index.js'

export default {
	data() {
		return {
			// #ifdef MP-WEIXIN
			mode: 'wechat',
			// #endif
			// #ifndef MP-WEIXIN
			mode: 'account',
			// #endif
			form: { username: '', password: '' },
			showPassword: false,
			focusField: '',
			passwordFocus: false,
			agreed: false,
			loading: false,
			rememberMe: true
		}
	},
	computed: {
		canLogin() {
			return this.form.username.trim() && this.form.password.trim()
		}
	},
	onLoad() {
		// 恢复记住的账号
		const saved = uni.getStorageSync('lifehub_saved_username')
		if (saved) {
			this.form.username = saved
			this.rememberMe = true
		}
	},
	methods: {
		toggleMode() {
			this.mode = this.mode === 'account' ? 'wechat' : 'account'
		},
		focusPassword() {
			this.passwordFocus = true
		},
		checkAgreement() {
			if (!this.agreed) {
				uni.showModal({
					title: '用户协议',
					content: '请先阅读并同意《用户协议》和《隐私政策》',
					confirmText: '同意',
					cancelText: '取消',
					success: (res) => {
						if (res.confirm) {
							this.agreed = true
						}
					}
				})
				return false
			}
			return true
		},
		async handleAccountLogin() {
			if (this.loading) return
			if (!this.form.username.trim()) {
				return uni.showToast({ title: '请输入账号', icon: 'none' })
			}
			if (!this.form.password.trim()) {
				return uni.showToast({ title: '请输入密码', icon: 'none' })
			}
			if (!this.checkAgreement()) return

			this.loading = true
			try {
				const res = await loginByAccount(this.form.username, this.form.password)
				setToken(res.token)
				setUser(res.user)

				// 记住账号
				if (this.rememberMe) {
					uni.setStorageSync('lifehub_saved_username', this.form.username)
				} else {
					uni.removeStorageSync('lifehub_saved_username')
				}

				uni.showToast({ title: '登录成功', icon: 'success' })
				setTimeout(() => {
					uni.reLaunch({ url: '/pages/home/home' })
				}, 500)
			} catch (e) {
				uni.showToast({ title: e.message || '登录失败', icon: 'none' })
			} finally {
				this.loading = false
			}
		},
		handleWechatLogin() {
			if (this.loading) return
			if (!this.checkAgreement()) return

			// #ifdef MP-WEIXIN
			this.loading = true
			uni.login({
				success: async (loginRes) => {
					try {
						// 获取用户信息
						let userInfo = null
						try {
							const profileRes = await new Promise((resolve, reject) => {
								uni.getUserProfile({
									desc: '用于完善用户资料',
									success: resolve,
									fail: reject
								})
							})
							userInfo = profileRes.userInfo
						} catch (e) {
							// 用户拒绝授权，仍然可以登录
						}

						const res = await loginByWx(loginRes.code, userInfo)
						setToken(res.token)
						setUser(res.user)
						uni.showToast({ title: '登录成功', icon: 'success' })
						setTimeout(() => {
							uni.reLaunch({ url: '/pages/home/home' })
						}, 500)
					} catch (e) {
						uni.showToast({ title: e.message || '登录失败', icon: 'none' })
					} finally {
						this.loading = false
					}
				},
				fail: () => {
					this.loading = false
					uni.showToast({ title: '微信登录调用失败', icon: 'none' })
				}
			})
			// #endif

			// #ifndef MP-WEIXIN
			uni.showToast({ title: '请在微信小程序中使用', icon: 'none' })
			// #endif
		},
		async handlePhoneLogin(e) {
			if (e.detail.errMsg !== 'getPhoneNumber:ok') {
				// 用户拒绝授权手机号，降级到普通微信登录
				return
			}
			if (!this.checkAgreement()) return

			// #ifdef MP-WEIXIN
			this.loading = true
			try {
				// 先获取登录 code
				const loginRes = await new Promise((resolve, reject) => {
					uni.login({ success: resolve, fail: reject })
				})

				const res = await loginByPhone({
					code: loginRes.code,
					phoneCode: e.detail.code,
					encryptedData: e.detail.encryptedData,
					iv: e.detail.iv
				})
				setToken(res.token)
				setUser(res.user)
				uni.showToast({ title: '登录成功', icon: 'success' })
				setTimeout(() => {
					uni.reLaunch({ url: '/pages/home/home' })
				}, 500)
			} catch (e) {
				uni.showToast({ title: e.message || '登录失败', icon: 'none' })
			} finally {
				this.loading = false
			}
			// #endif
		}
	}
}
</script>

<style lang="scss" scoped>
.login-page {
	min-height: 100vh;
	background: linear-gradient(180deg, #ecfdf5 0%, #f0fdf4 30%, #ffffff 100%);
	padding: 0 48rpx;
	display: flex;
	flex-direction: column;
}

.login-header {
	padding-top: 120rpx;
	margin-bottom: 48rpx;
	position: relative;
	display: flex;
	flex-direction: column;
	align-items: center;
}

.header-circle {
	position: absolute;
	border-radius: 50%;
	opacity: 0.6;
}

.c1 {
	width: 240rpx;
	height: 240rpx;
	background: rgba(16, 185, 129, 0.06);
	top: 40rpx;
	right: -60rpx;
}

.c2 {
	width: 160rpx;
	height: 160rpx;
	background: rgba(14, 165, 233, 0.05);
	top: 180rpx;
	left: -40rpx;
}

.c3 {
	width: 100rpx;
	height: 100rpx;
	background: rgba(245, 158, 11, 0.05);
	top: 60rpx;
	left: 100rpx;
}

.logo-wrap {
	width: 120rpx;
	height: 120rpx;
	border-radius: 28rpx;
	background: linear-gradient(135deg, #059669, #10b981);
	display: flex;
	align-items: center;
	justify-content: center;
	margin-bottom: 24rpx;
	box-shadow: 0 8rpx 32rpx rgba(5, 150, 105, 0.3);
}

.logo-icon {
	font-size: 56rpx;
}

.app-name {
	font-size: 48rpx;
	font-weight: 800;
	color: #1a1a1a;
	margin-bottom: 8rpx;
}

.app-desc {
	font-size: 26rpx;
	color: #999;
}

.login-card {
	background: #ffffff;
	border-radius: 28rpx;
	padding: 40rpx 32rpx;
	box-shadow: 0 4rpx 40rpx rgba(0, 0, 0, 0.06);
}

.input-group {
	margin-bottom: 24rpx;
}

.input-wrap {
	display: flex;
	align-items: center;
	background: #f8f9fa;
	border-radius: 16rpx;
	padding: 0 24rpx;
	height: 96rpx;
	border: 2rpx solid transparent;
	transition: all 0.25s;

	&.input-focus {
		border-color: #10b981;
		background: #ffffff;
		box-shadow: 0 0 0 6rpx rgba(16, 185, 129, 0.08);
	}
}

.input-icon {
	font-size: 30rpx;
	margin-right: 16rpx;
	flex-shrink: 0;
}

.input-field {
	flex: 1;
	font-size: 30rpx;
	color: #1a1a1a;
	height: 96rpx;
}

.input-eye {
	font-size: 32rpx;
	padding: 12rpx;
	flex-shrink: 0;
}

.form-actions {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 8rpx;
}

.remember-me {
	display: flex;
	align-items: center;
	gap: 8rpx;
}

.remember-text {
	font-size: 24rpx;
	color: #999;
}

.login-btn {
	background: linear-gradient(135deg, #059669, #10b981);
	border-radius: 16rpx;
	height: 96rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	margin-top: 28rpx;
	box-shadow: 0 6rpx 20rpx rgba(5, 150, 105, 0.3);
	transition: opacity 0.2s, transform 0.1s;

	&:active {
		transform: scale(0.98);
	}

	&.btn-disabled {
		opacity: 0.5;
	}
}

.login-btn-text {
	color: #ffffff;
	font-size: 32rpx;
	font-weight: 600;
	letter-spacing: 6rpx;
}

/* 微信登录区域 */
.wechat-section {
	display: flex;
	flex-direction: column;
	align-items: center;
	padding: 20rpx 0;
}

.wechat-avatar-wrap {
	width: 100rpx;
	height: 100rpx;
	border-radius: 50%;
	background: rgba(7, 193, 96, 0.08);
	display: flex;
	align-items: center;
	justify-content: center;
	margin-bottom: 20rpx;
}

.wechat-avatar-icon {
	font-size: 48rpx;
}

.wechat-title {
	font-size: 32rpx;
	font-weight: 600;
	color: #1a1a1a;
	margin-bottom: 8rpx;
}

.wechat-desc {
	font-size: 24rpx;
	color: #999;
	margin-bottom: 36rpx;
}

.phone-login-btn {
	width: 100%;
	height: 96rpx;
	background: linear-gradient(135deg, #07c160, #2aae67);
	border-radius: 16rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 12rpx;
	margin-bottom: 20rpx;
	border: none;
	box-shadow: 0 6rpx 20rpx rgba(7, 193, 96, 0.3);
	padding: 0;
	line-height: 96rpx;

	&::after {
		border: none;
	}

	&:active {
		transform: scale(0.98);
	}
}

.phone-btn-icon {
	font-size: 28rpx;
}

.phone-btn-text {
	color: #ffffff;
	font-size: 30rpx;
	font-weight: 600;
}

.wx-login-btn {
	width: 100%;
	height: 88rpx;
	background: #f8f9fa;
	border-radius: 16rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	transition: all 0.2s;

	&:active {
		background: #f0f0f0;
	}

	&.btn-disabled {
		opacity: 0.5;
	}

	&.disabled {
		opacity: 0.4;
	}
}

.wx-btn-text {
	color: #666;
	font-size: 28rpx;
	font-weight: 500;
}

/* 切换方式 */
.switch-mode {
	margin-top: 36rpx;
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 20rpx;
}

.switch-divider {
	display: flex;
	align-items: center;
	gap: 20rpx;
	width: 100%;
}

.divider-line {
	flex: 1;
	height: 1rpx;
	background: #e5e7eb;
}

.divider-text {
	font-size: 24rpx;
	color: #ccc;
}

.switch-text {
	font-size: 26rpx;
	color: #059669;
	font-weight: 500;
	padding: 8rpx 24rpx;
}

/* 协议 */
.agreement {
	margin-top: auto;
	padding: 32rpx 0 60rpx;
}

.agree-check {
	display: flex;
	align-items: flex-start;
	gap: 12rpx;
	justify-content: center;
}

.check-box {
	width: 32rpx;
	height: 32rpx;
	border-radius: 6rpx;
	border: 2rpx solid #ddd;
	display: flex;
	align-items: center;
	justify-content: center;
	flex-shrink: 0;
	margin-top: 2rpx;
	transition: all 0.2s;

	&.checked {
		background: #059669;
		border-color: #059669;
	}

	&.small {
		width: 28rpx;
		height: 28rpx;
		border-radius: 4rpx;
	}
}

.check-icon {
	color: #fff;
	font-size: 18rpx;
	font-weight: 700;
}

.agree-text {
	font-size: 22rpx;
	color: #999;
	line-height: 1.6;
}

.agree-link {
	color: #059669;
}
</style>
