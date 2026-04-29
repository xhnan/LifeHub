<template>
	<!-- 优先用预下载的本地图标，fallback 到 Iconify API -->
	<image
		v-if="iconSrc"
		:src="iconSrc"
		class="dyn-icon"
		:style="{ width: size + 'rpx', height: size + 'rpx' }"
		mode="aspectFit"
	/>
	<text v-else class="dyn-icon-fallback" :style="{ fontSize: size * 0.7 + 'rpx' }">{{ fallback }}</text>
</template>

<script>
// 本地图标映射：直接用 Iconify code 的图标名部分匹配 static/icons/ 下的文件
// 规则：mdi:bank → /static/icons/bank.svg
// 如果有新图标，只需把 SVG 下载到 static/icons/ 即可

export default {
	name: 'DynIcon',
	props: {
		icon: { type: String, default: '' },
		size: { type: Number, default: 36 }
	},
	computed: {
		iconSrc() {
			if (!this.icon) return ''
			// 已经是本地路径或完整 URL
			if (this.icon.startsWith('/static/') || this.icon.startsWith('http')) {
				return this.icon
			}
			// Iconify 代码：mdi:bank → /static/icons/bank.svg
			const parts = this.icon.split(':')
			if (parts.length === 2) {
				return `/static/icons/${parts[1]}.svg`
			}
			return ''
		},
		fallback() {
			if (!this.icon) return '📋'
			if (this.icon.startsWith('/static/') || this.icon.startsWith('http')) return '📋'
			const name = this.icon.split(':').pop() || ''
			// 简单 emoji fallback
			const map = {
				bank: '🏦', wallet: '📱', credit: '💳', cellphone: '💬',
				chart: '📈', food: '🍜', car: '🚗', cart: '🛒',
				home: '🏠', gamepad: '🎮', hospital: '🏥', school: '📚',
				spray: '🧴', briefcase: '💼', cash: '💰', gift: '🎁',
				swap: '🔄', dots: '💰', keyboard: '↩️'
			}
			for (const [key, emoji] of Object.entries(map)) {
				if (name.includes(key)) return emoji
			}
			return '📋'
		}
	}
}
</script>

<style lang="scss" scoped>
.dyn-icon {
	display: inline-block;
	vertical-align: middle;
}

.dyn-icon-fallback {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	line-height: 1;
}
</style>
