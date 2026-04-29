// Mock 数据 - 后续对接后端时替换

// 资产总览
export const assetOverview = {
  totalAsset: 328450.00,
  totalLiability: 39250.00,
  netWorth: 289200.00,
  assetChange: 2350.00,
  liabilityChange: -500.00,
  netWorthChange: 2850.00
}

// 账户列表 - icon 改为 Iconify 代码
export const accounts = [
  { id: 1, name: '招商银行储蓄卡', type: 'bank', icon: 'mdi:bank', balance: 152300.00 },
  { id: 2, name: '支付宝余额', type: 'ewallet', icon: 'mdi:wallet', balance: 37850.50 },
  { id: 3, name: '微信零钱', type: 'ewallet', icon: 'mdi:cellphone', balance: 2150.30 },
  { id: 4, name: '工商银行储蓄卡', type: 'bank', icon: 'mdi:bank', balance: 89400.00 },
  { id: 5, name: '天天基金', type: 'investment', icon: 'mdi:chart-line', balance: 46750.20 },
  { id: 6, name: '招商信用卡', type: 'credit', icon: 'mdi:credit-card', balance: -8920.00 },
  { id: 7, name: '花呗', type: 'credit', icon: 'mdi:credit-card', balance: -3030.00 }
]

// 收支分类
export const categories = {
  income: ['工资', '奖金', '理财收益', '转账收入', '退款', '其他收入'],
  expense: ['餐饮', '交通', '购物', '住房', '娱乐', '医疗', '教育', '通讯', '日用品', '其他支出']
}

// 收支记录
export const records = generateRecords()

function generateRecords() {
  const data = []
  const expenseItems = [
    { category: '餐饮', icon: 'mdi:food', items: ['午餐外卖', '星巴克咖啡', '晚餐火锅', '早餐包子', '下午茶奶茶'] },
    { category: '交通', icon: 'mdi:car', items: ['地铁充值', '滴滴打车', '共享单车', '加油', '停车费'] },
    { category: '购物', icon: 'mdi:cart', items: ['淘宝日用品', '京东数码', '超市采购', '衣服鞋子', '书籍'] },
    { category: '住房', icon: 'mdi:home', items: ['房租', '水电费', '物业费', '燃气费'] },
    { category: '娱乐', icon: 'mdi:gamepad-variant', items: ['电影票', '游戏充值', 'KTV', '健身房月卡', '视频会员'] },
    { category: '医疗', icon: 'mdi:hospital-box', items: ['门诊挂号', '药品', '体检'] },
    { category: '教育', icon: 'mdi:school', items: ['网课', '书籍', '考试报名费'] },
    { category: '通讯', icon: 'mdi:cellphone-wireless', items: ['话费充值', '宽带费'] },
    { category: '日用品', icon: 'mdi:spray-bottle', items: ['洗衣液', '纸巾', '洗发水'] },
    { category: '其他支出', icon: 'mdi:dots-horizontal', items: ['红包', '转账', '还款'] }
  ]
  const incomeItems = [
    { category: '工资', icon: 'mdi:briefcase', items: ['月度工资'] },
    { category: '奖金', icon: 'mdi:gift', items: ['季度奖金', '年终奖'] },
    { category: '理财收益', icon: 'mdi:chart-areaspline', items: ['基金分红', '余额宝收益', '理财利息'] },
    { category: '转账收入', icon: 'mdi:swap-horizontal', items: ['朋友转账', '报销'] },
    { category: '退款', icon: 'mdi:keyboard-return', items: ['退货退款', '订单取消'] },
    { category: '其他收入', icon: 'mdi:cash', items: ['闲鱼出售', '红包收入'] }
  ]

  const accountNames = ['招商银行储蓄卡', '支付宝余额', '微信零钱', '工商银行储蓄卡']

  for (let dayOffset = 0; dayOffset < 30; dayOffset++) {
    const date = new Date()
    date.setDate(date.getDate() - dayOffset)
    const dateStr = formatDate(date)

    const expenseCount = 2 + Math.floor(Math.random() * 5)
    for (let i = 0; i < expenseCount; i++) {
      const item = expenseItems[Math.floor(Math.random() * expenseItems.length)]
      const amount = (Math.random() * 200 + 5).toFixed(2)
      data.push({
        id: `e${dayOffset}_${i}`,
        type: 'expense',
        category: item.category,
        icon: item.icon,
        amount: parseFloat(amount),
        note: item.items[Math.floor(Math.random() * item.items.length)],
        account: accountNames[Math.floor(Math.random() * accountNames.length)],
        date: dateStr,
        timestamp: date.getTime() - Math.floor(Math.random() * 86400000)
      })
    }

    if (dayOffset % 3 === 0 || dayOffset === 0) {
      const item = incomeItems[Math.floor(Math.random() * incomeItems.length)]
      let amount
      if (item.category === '工资') {
        amount = 15000 + Math.floor(Math.random() * 5000)
      } else if (item.category === '理财收益') {
        amount = (Math.random() * 500 + 10).toFixed(2)
      } else {
        amount = (Math.random() * 2000 + 50).toFixed(2)
      }
      data.push({
        id: `i${dayOffset}`,
        type: 'income',
        category: item.category,
        icon: item.icon,
        amount: parseFloat(amount),
        note: item.items[Math.floor(Math.random() * item.items.length)],
        account: accountNames[Math.floor(Math.random() * accountNames.length)],
        date: dateStr,
        timestamp: date.getTime() - Math.floor(Math.random() * 86400000)
      })
    }
  }

  return data.sort((a, b) => b.timestamp - a.timestamp)
}

function formatDate(date) {
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, '0')
  const d = String(date.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}
