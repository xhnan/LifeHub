import '../../../../shared/models/psy_assessment.dart';

class AssessmentDataSource {
  static List<AssessmentQuestion> getPHQ9Questions() {
    return [
      AssessmentQuestion(
        index: 0,
        question: '做事时提不起劲或没有兴趣',
        options: [
          AssessmentOption(value: 0, label: '完全不会'),
          AssessmentOption(value: 1, label: '好几天'),
          AssessmentOption(value: 2, label: '一半以上的天数'),
          AssessmentOption(value: 3, label: '几乎每天'),
        ],
      ),
      AssessmentQuestion(
        index: 1,
        question: '感到心情低落、沮丧或绝望',
        options: [
          AssessmentOption(value: 0, label: '完全不会'),
          AssessmentOption(value: 1, label: '好几天'),
          AssessmentOption(value: 2, label: '一半以上的天数'),
          AssessmentOption(value: 3, label: '几乎每天'),
        ],
      ),
      AssessmentQuestion(
        index: 2,
        question: '入睡困难、睡不安稳或睡眠过多',
        options: [
          AssessmentOption(value: 0, label: '完全不会'),
          AssessmentOption(value: 1, label: '好几天'),
          AssessmentOption(value: 2, label: '一半以上的天数'),
          AssessmentOption(value: 3, label: '几乎每天'),
        ],
      ),
      AssessmentQuestion(
        index: 3,
        question: '感觉疲倦或没有活力',
        options: [
          AssessmentOption(value: 0, label: '完全不会'),
          AssessmentOption(value: 1, label: '好几天'),
          AssessmentOption(value: 2, label: '一半以上的天数'),
          AssessmentOption(value: 3, label: '几乎每天'),
        ],
      ),
      AssessmentQuestion(
        index: 4,
        question: '食欲不振或吃太多',
        options: [
          AssessmentOption(value: 0, label: '完全不会'),
          AssessmentOption(value: 1, label: '好几天'),
          AssessmentOption(value: 2, label: '一半以上的天数'),
          AssessmentOption(value: 3, label: '几乎每天'),
        ],
      ),
      AssessmentQuestion(
        index: 5,
        question: '觉得自己很糟或觉得自己很失败，或让自己或家人失望',
        options: [
          AssessmentOption(value: 0, label: '完全不会'),
          AssessmentOption(value: 1, label: '好几天'),
          AssessmentOption(value: 2, label: '一半以上的天数'),
          AssessmentOption(value: 3, label: '几乎每天'),
        ],
      ),
      AssessmentQuestion(
        index: 6,
        question: '对事物专注有困难，例如阅读报纸或看电视',
        options: [
          AssessmentOption(value: 0, label: '完全不会'),
          AssessmentOption(value: 1, label: '好几天'),
          AssessmentOption(value: 2, label: '一半以上的天数'),
          AssessmentOption(value: 3, label: '几乎每天'),
        ],
      ),
      AssessmentQuestion(
        index: 7,
        question: '动作或说话速度缓慢到别人已经注意到，或正好相反，比平常活动多得多',
        options: [
          AssessmentOption(value: 0, label: '完全不会'),
          AssessmentOption(value: 1, label: '好几天'),
          AssessmentOption(value: 2, label: '一半以上的天数'),
          AssessmentOption(value: 3, label: '几乎每天'),
        ],
      ),
      AssessmentQuestion(
        index: 8,
        question: '有不如死掉或用某种方式伤害自己的念头',
        options: [
          AssessmentOption(value: 0, label: '完全不会'),
          AssessmentOption(value: 1, label: '好几天'),
          AssessmentOption(value: 2, label: '一半以上的天数'),
          AssessmentOption(value: 3, label: '几乎每天'),
        ],
      ),
    ];
  }

  static List<AssessmentQuestion> getGAD7Questions() {
    return [
      AssessmentQuestion(
        index: 0,
        question: '感觉紧张、焦虑或急切',
        options: [
          AssessmentOption(value: 0, label: '完全不会'),
          AssessmentOption(value: 1, label: '好几天'),
          AssessmentOption(value: 2, label: '一半以上的天数'),
          AssessmentOption(value: 3, label: '几乎每天'),
        ],
      ),
      AssessmentQuestion(
        index: 1,
        question: '不能够停止或控制担忧',
        options: [
          AssessmentOption(value: 0, label: '完全不会'),
          AssessmentOption(value: 1, label: '好几天'),
          AssessmentOption(value: 2, label: '一半以上的天数'),
          AssessmentOption(value: 3, label: '几乎每天'),
        ],
      ),
      AssessmentQuestion(
        index: 2,
        question: '对各种各样的事情担忧过多',
        options: [
          AssessmentOption(value: 0, label: '完全不会'),
          AssessmentOption(value: 1, label: '好几天'),
          AssessmentOption(value: 2, label: '一半以上的天数'),
          AssessmentOption(value: 3, label: '几乎每天'),
        ],
      ),
      AssessmentQuestion(
        index: 3,
        question: '很难放松下来',
        options: [
          AssessmentOption(value: 0, label: '完全不会'),
          AssessmentOption(value: 1, label: '好几天'),
          AssessmentOption(value: 2, label: '一半以上的天数'),
          AssessmentOption(value: 3, label: '几乎每天'),
        ],
      ),
      AssessmentQuestion(
        index: 4,
        question: '由于不安而无法静坐',
        options: [
          AssessmentOption(value: 0, label: '完全不会'),
          AssessmentOption(value: 1, label: '好几天'),
          AssessmentOption(value: 2, label: '一半以上的天数'),
          AssessmentOption(value: 3, label: '几乎每天'),
        ],
      ),
      AssessmentQuestion(
        index: 5,
        question: '变得容易烦恼或急躁',
        options: [
          AssessmentOption(value: 0, label: '完全不会'),
          AssessmentOption(value: 1, label: '好几天'),
          AssessmentOption(value: 2, label: '一半以上的天数'),
          AssessmentOption(value: 3, label: '几乎每天'),
        ],
      ),
      AssessmentQuestion(
        index: 6,
        question: '感到似乎将有可怕的事情发生',
        options: [
          AssessmentOption(value: 0, label: '完全不会'),
          AssessmentOption(value: 1, label: '好几天'),
          AssessmentOption(value: 2, label: '一半以上的天数'),
          AssessmentOption(value: 3, label: '几乎每天'),
        ],
      ),
    ];
  }

  static String getPHQ9Severity(int score) {
    if (score <= 4) return '无抑郁';
    if (score <= 9) return '轻度抑郁';
    if (score <= 14) return '中度抑郁';
    if (score <= 19) return '中重度抑郁';
    return '重度抑郁';
  }

  static String getGAD7Severity(int score) {
    if (score <= 4) return '无焦虑';
    if (score <= 9) return '轻度焦虑';
    if (score <= 14) return '中度焦虑';
    return '重度焦虑';
  }

  static String getPHQ9Analysis(int score) {
    if (score <= 4) {
      return '您的抑郁症状评估结果为无抑郁。请继续保持健康的生活方式。';
    } else if (score <= 9) {
      return '您的抑郁症状评估结果为轻度抑郁。建议您关注自己的情绪变化，保持规律作息和适当运动。如有需要，可寻求专业心理咨询。';
    } else if (score <= 14) {
      return '您的抑郁症状评估结果为中度抑郁。建议您尽快寻求专业心理咨询或治疗。同时，保持与亲友的沟通，避免独处。';
    } else if (score <= 19) {
      return '您的抑郁症状评估结果为中重度抑郁。强烈建议您尽快寻求专业心理治疗。如感到痛苦，请拨打心理援助热线。';
    } else {
      return '您的抑郁症状评估结果为重度抑郁。请立即寻求专业心理治疗。如您有任何伤害自己的想法，请立即拨打急救电话或心理援助热线。';
    }
  }

  static String getGAD7Analysis(int score) {
    if (score <= 4) {
      return '您的焦虑症状评估结果为无焦虑。请继续保持健康的生活方式。';
    } else if (score <= 9) {
      return '您的焦虑症状评估结果为轻度焦虑。建议您学习放松技巧，如深呼吸、冥想等。保持规律作息，避免过度压力。';
    } else if (score <= 14) {
      return '您的焦虑症状评估结果为中度焦虑。建议您寻求专业心理咨询。同时，尝试减少压力源，保持适当的运动和休息。';
    } else {
      return '您的焦虑症状评估结果为重度焦虑。强烈建议您尽快寻求专业心理治疗。如感到痛苦，请拨打心理援助热线。';
    }
  }
}
