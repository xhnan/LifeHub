<template>
	<view class="health-score">
		<view class="score-ring">
			<view class="ring-outer">
				<view class="ring-inner">
					<text class="score-num">{{ score }}</text>
					<text class="score-label">财务健康分</text>
				</view>
			</view>
		</view>
		<view class="score-level" :style="{ color: levelColor }">{{ level }}</view>
		<view class="score-desc">{{ description }}</view>
	</view>
</template>

<script>
export default {
	name: 'HealthScore',
	props: {
		savingRate: { type: Number, default: 0 },
		balance: { type: Number, default: 0 }
	},
	computed: {
		score() {
			// 简单评分：储蓄率权重 + 结余权重
			let s = 0
			if (this.savingRate >= 50) s += 50
			else if (this.savingRate >= 30) s += 40
			else if (this.savingRate >= 20) s += 30
			else if (this.savingRate >= 10) s += 20
			else s += 10

			if (this.balance > 0) s += 40
			else s += 10

			s += Math.min(Math.floor(this.savingRate / 2), 10)
			return Math.min(s, 100)
		},
		level() {
			if (this.score >= 90) return '极好'
			if (this.score >= 75) return '良好'
			if (this.score >= 60) return '一般'
			if (this.score >= 40) return '需改善'
			return '预警'
		},
		levelColor() {
			if (this.score >= 75) return '#059669'
			if (this.score >= 60) return '#f59e0b'
			return '#ef4444'
		},
		description() {
			if (this.score >= 90) return '财务状况非常健康，继续保持！'
			if (this.score >= 75) return '收支平衡良好，储蓄率不错。'
			if (this.score >= 60) return '收支基本平衡，建议控制支出。'
			if (this.score >= 40) return '支出偏高，建议制定预算计划。'
			return '入不敷出，请立即审视消费习惯！'
		}
	}
}
</script>

<style lang="scss" scoped>
.health-score {
	background: linear-gradient(135deg, #059669, #10b981, #34d399);
	border-radius: 24rpx;
	padding: 40rpx 28rpx;
	display: flex;
	flex-direction: column;
	align-items: center;
	box-shadow: 0 4rpx 24rpx rgba(5, 150, 105, 0.3);
}

.score-ring {
	margin-bottom: 16rpx;
}

.ring-outer {
	width: 180rpx;
	height: 180rpx;
	border-radius: 50%;
	background: rgba(255, 255, 255, 0.2);
	display: flex;
	align-items: center;
	justify-content: center;
}

.ring-inner {
	width: 140rpx;
	height: 140rpx;
	border-radius: 50%;
	background: rgba(255, 255, 255, 0.95);
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
}

.score-num {
	font-size: 48rpx;
	font-weight: 800;
	color: #059669;
	font-family: 'Georgia', serif;
}

.score-label {
	font-size: 18rpx;
	color: #999;
	margin-top: 2rpx;
}

.score-level {
	font-size: 32rpx;
	font-weight: 700;
	margin-bottom: 8rpx;
}

.score-desc {
	font-size: 24rpx;
	color: rgba(255, 255, 255, 0.85);
	text-align: center;
}
</style>
