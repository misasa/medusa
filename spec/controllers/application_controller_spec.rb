require 'spec_helper'

describe ApplicationController do
  describe ".adjust_url_by_requesting_tab" do
    subject{ @controller.adjust_url_by_requesting_tab(url) }
    let(:tabname){"analysis"}
    let(:base_url){"http://wwww.test.co.jp/"}
    let(:tab_param){"tab=#{tabname}"}
    let(:other_param){"aaa=aaa"}
    let(:other_tab_param){"tab=aaa"}
    before{@controller.params[:tab] = tab}
    context "none tab param" do
      let(:tab){""}
      let(:url){base_url}
      it { expect(subject).to eq base_url}
    end
    context "present tab param" do
      let(:tab){tabname}
      context "none tab param in url" do
        context "none other param in url" do
          let(:url){base_url}
          it { expect(subject).to eq "#{base_url}?#{tab_param}"}
        end
        context "present other param in url" do
          let(:url){"#{base_url}?#{other_param}"}
          it { expect(subject).to eq "#{base_url}?#{other_param}&#{tab_param}"}
        end
      end
      context "present tab param in url" do
        context "none other param in url" do
          let(:url){"#{base_url}?#{other_tab_param}"}
          it { expect(subject).to eq "#{base_url}?#{tab_param}"}
        end
        context "present other param in url" do
          let(:url){"#{base_url}?#{other_tab_param}&#{other_param}"}
          it { expect(subject).to eq "#{base_url}?#{other_param}&#{tab_param}"}
        end
      end
    end
  end
end
