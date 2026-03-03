class PagesController < ApplicationController
  def home
    # TODO: replace with real data from DB
    @top_players = build_top_players
    @classrooms_data = build_classrooms_data
  end

  private

  def build_top_players
    names = %w[木子KANKAN 夜枭神君 暗影刺客 冰霜骑士 烈焰法师 风行浪子 圣堂执剑 敌法大帝 幻影长矛 雷霆宙斯]
    scores = [ 342, 298, 276, 251, 224, 198, 175, 153, 121, 98 ]
    max = scores.first.to_f
    names.zip(scores).map { |name, score| { name:, score:, pct: (score / max * 100).round } }
  end

  SURNAMES    = %w[赵 钱 孙 李 周 吴 郑 王 冯 陈 楚 蒋 沈 韩 杨 朱 秦 许 何 吕 施 张 孔 曹 严 华 金 魏 许 邓].freeze
  GIVEN_NAMES = %w[伟 芳 敏 静 丽 强 磊 军 洋 勇 艳 杰 娟 涛 明 超 霞 平 刚 玲 斌 辉 飞 博 坤 俊 旭 鹏 宇 浩 晨 龙 彬 哲 妍 璐].freeze

  def build_classrooms_data
    Array.new(20) do |ci|
      {
        number: ci + 1,
        groups: Array.new(5) do |gi|
          {
            number: gi + 1,
            players: Array.new(5) do
              {
                name: SURNAMES.sample + GIVEN_NAMES.sample + GIVEN_NAMES.sample,
                contributions: Array.new(28) { rand(0..7) }
              }
            end
          }
        end
      }
    end
  end
end
