<template>
	<view class="login-page">
		<!-- 顶部装饰 -->
		<view class="login-header">
			<view class="header-circle c1"></view>
			<view class="header-circle c2"></view>
			<text class="app-name">LifeHub 财务</text>
			<text class="app-desc">你的智能财务助手</text>
		</view>

		<!-- 登录表单 -->
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
					/>
					<text class="input-eye" @click="showPassword = !showPassword">
						{{ showPassword ? '👁' : '👁‍🗨' }}
					</text>
				</view>
			</view>
			<view class="login-btn" @click="handleAccountLogin" :class="{ 'btn-disabled': loading }">
				<text class="login-btn-text">{{ loading ? '登录中...' : '登 录' }}</text>
			</view>
		</view>

		<!-- 微信登录 -->
		<view class="login-card" v-if="mode === 'wechat'">
			<view class="wechat-section">
				<view class="wechat-icon-wrap">
					<text class="wechat-icon">💬</text>
				</view>
				<text class="wechat-desc">使用微信账号快速登录</text>
				<view class="login-btn wechat-btn" @click="handleWechatLogin" :class="{ 'btn-disabled': loading }">
					<text class="login-btn-text">{{ loading ? '登录中...' : '微信一键登录' }}</text>
				</view>
			</view>
		</view>

		<!-- 切换登录方式 -->
		<view class="switch-mode">
			<text class="switch-text" @click="toggleMode">
				{{ mode === 'account' ? '使用微信登录' : '使用账号密码登录' }}
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
import { loginByAccount, loginByWx } from '../../api/index.js'

export default {
	data() {
		return {
			mode: 'account',
			form: { username: '', password: '' },
			showPassword: false,
			focusField: '',
			agreed: false,
			loading: false
		}
	},
	methods: {
		toggleMode() {
			this.mode = this.mode === 'account' ? 'wechat' : 'account'
		},
		async handleAccountLogin() {
			if (this.loading) return
			if (!this.form.username.trim()) {
				return uni.showToast({ title: '请输入账号', icon: 'none' })
			}
			if (!this.form.password.trim()) {
				return uni.showToast({ title: '请输入密码', icon: 'none' })
			}
			if (!this.agreed) {
				return uni.showToast({ title: '请先同意用户协议', icon: 'none' })
			}

			this.loading = true
			try {
				const res = await loginByAccount(this.form.username, this.form.password)
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
		handleWechatLogin() {
			if (this.loading) return
			if (!this.agreed) {
				return uni.showToast({ title: '请先同意用户协议', icon: 'none' })
			}

			// #ifdef MP-WEIXIN
			uni.login({
				success: async (loginRes) => {
					this.loading = true
					try {
						const res = await loginByWx(loginRes.code)
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
				}
			})
			// #endif

			// #ifndef MP-WEIXIN
			uni.showToast({ title: '请在微信小程序中使用', icon: 'none' })
			// #endif
		}
	}
}
</script>

<style lang="scss" scoped>
.login-page {
	min-height: 100vh;
	background: linear-gradient(180deg, #ecfdf5 0%, #f0fdf4 40%, #ffffff 100%);
	padding: 0 48rpx;
	display: flex;
	flex-direction: column;
}

.login-header {
	padding-top: 160rpx;
	margin-bottom: 60rpx;
	position: relative;
}

.header-circle {
	position: absolute;
	border-radius: 50%;
}

.c1 {
	width: 200rpx;
	height: 200rpx;
	background: rgba(16, 185, 129, 0.08);
	top: 80rpx;
	right: -40rpx;
}

.c2 {
	width: 120rpx;
	height: 120rpx;
	background: rgba(14, 165, 233, 0.06);
	top: 200rpx;
	right: 80rpx;
}

.app-name {
	font-size: 52rpx;
	font-weight: 800;
	color: #1a1a1a;
	display: block;
	margin-bottom: 12rpx;
}

.app-desc {
	font-size: 28rpx;
	color: #999;
}

.login-card {
	background: #ffffff;
	border-radius: 28rpx;
	padding: 40rpx 32rpx;
	box-shadow: 0 4rpx 32rpx rgba(0, 0, 0, 0.06);
}

.input-group {
	margin-bottom: 28rpx;
}

.input-wrap {
	display: flex;
	align-items: center;
	background: #f8f9fa;
	border-radius: 16rpx;
	padding: 0 24rpx;
	height: 96rpx;
	border: 2rpx solid transparent;
	transition: all 0.2s;

	&.input-focus {
		border-color: #10b981;
		background: #ffffff;
		box-shadow: 0 0 0 4rpx rgba(16, 185, 129, 0.1);
	}
}

.input-icon {
	font-size: 32rpx;
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
	padding: 8rpx;
	flex-shrink: 0;
}

.login-btn {
	background: linear-gradient(135deg, #059669, #10b981);
	border-radius: 16rpx;
	height: 96rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	margin-top: 36rpx;
	box-shadow: 0 4rpx 16rpx rgba(5, 150, 105, 0.3);

	&.btn-disabled {
		opacity: 0.6;
	}
}

.wechat-btn {
	background: linear-gradient(135deg, #07c160, #2aae67);
	box-shadow: 0 4rpx 16rpx rgba(7, 193, 96, 0.3);
}

.login-btn-text {
	color: #ffffff;
	font-size: 32rpx;
	font-weight: 600;
	letter-spacing: 4rpx;
}

.wechat-section {
	display: flex;
	flex-direction: column;
	align-items: center;
	padding: 20rpx 0;
}

.wechat-icon-wrap {
	width: 120rpx;
	height: 120rpx;
	background: rgba(7, 193, 96, 0.1);
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
	margin-bottom: 24rpx;
}

.wechat-icon {
	font-size: 56rpx;
}

.wechat-desc {
	font-size: 26rpx;
	color: #999;
	margin-bottom: 40rpx;
}

.switch-mode {
	text-align: center;
	margin-top: 36rpx;
}

.switch-text {
	font-size: 26rpx;
	color: #059669;
	font-weight: 500;
}

.agreement {
	margin-top: auto;
	padding: 40rpx 0 60rpx;
}

.agree-check {
	display: flex;
	align-items: flex-start;
	gap: 12rpx;
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

	&.checked {
		background: #059669;
		border-color: #059669;
	}
}

.check-icon {
	color: #fff;
	font-size: 20rpx;
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
