require 'spec_helper'

describe Quantity do
  describe "class methods" do
    describe "quantity" do
      subject { Quantity.quantity(decimal_quantity) }
      context "exponent is 0" do
        context "decimal_quantity is 999.999" do
          let(:decimal_quantity) { 999.999.to_d }
          it { expect(subject).to eq 999.999 }
        end
        context "decimal_quantity is   1.000" do
          let(:decimal_quantity) { 1.000.to_d }
          it { expect(subject).to eq 1.0 }
        end
      end
      context "exponent is 3" do
        context "decimal_quantity is 999999.0" do
          let(:decimal_quantity) { 999999.0.to_d }
          it { expect(subject).to eq 999.999 }
        end
        context "decimal_quantity is   1000.000" do
          let(:decimal_quantity) { 1000.0.to_d }
          it { expect(subject).to eq 1.0 }
        end
      end
      context "exponent is -3" do
        context "decimal_quantity is 0.999999" do
          let(:decimal_quantity) { 0.999999.to_d }
          it { expect(subject).to eq 999.999 }
        end
        context "decimal_quantity is 0.001" do
          let(:decimal_quantity) { 0.001.to_d }
          it { expect(subject).to eq 1.0 }
        end
      end
    end

    describe "quantity_unit" do
      subject { Quantity.quantity_unit(decimal_quantity) }
      context "exponent is 0" do
        context "decimal_quantity is 999.999" do
          let(:decimal_quantity) { 999.999.to_d }
          it { expect(subject).to eq "g" }
        end
        context "decimal_quantity is   1.000" do
          let(:decimal_quantity) { 1.000.to_d }
          it { expect(subject).to eq "g" }
        end
      end
      context "exponent is 3" do
        context "decimal_quantity is 999999.0" do
          let(:decimal_quantity) { 999999.0.to_d }
          it { expect(subject).to eq "kg" }
        end
        context "decimal_quantity is   1000.000" do
          let(:decimal_quantity) { 1000.0.to_d }
          it { expect(subject).to eq "kg" }
        end
      end
      context "exponent is -3" do
        context "decimal_quantity is 0.999999" do
          let(:decimal_quantity) { 0.999999.to_d }
          it { expect(subject).to eq "mg" }
        end
        context "decimal_quantity is 0.001" do
          let(:decimal_quantity) { 0.001.to_d }
          it { expect(subject).to eq "mg" }
        end
      end
    end

    describe "exponent" do
      subject { Quantity.exponent(decimal_quantity) }
      context "below max and above min" do
        context "exponent is 0" do
          context "decimal_quantity is 999.999" do
            let(:decimal_quantity) { 999.999.to_d }
            it { expect(subject).to eq 0.0 }
          end
          context "decimal_quantity is   1.000" do
            let(:decimal_quantity) { 1.000.to_d }
            it { expect(subject).to eq 0.0 }
          end
        end
        context "exponent is 3" do
          context "decimal_quantity is 999999.0" do
            let(:decimal_quantity) { 99999.0.to_d }
            it { expect(subject).to eq 3.0 }
          end
          context "decimal_quantity is   1000.0" do
            let(:decimal_quantity) { 1000.0.to_d }
            it { expect(subject).to eq 3.0 }
          end
        end
        context "exponent is -3" do
          context "decimal_quantity is 0.999999" do
            let(:decimal_quantity) { 0.999999.to_d }
            it { expect(subject).to eq -3.0 }
          end
          context "decimal_quantity is 0.001" do
            let(:decimal_quantity) { 0.001.to_d }
            it { expect(subject).to eq -3.0 }
          end
        end
      end
      context "above max" do
        context "decimal_quantity is 1.0E24" do
          let(:decimal_quantity) { 1.0e+24.to_d }
          it { expect(subject).to eq 24.0 }
        end
        context "decimal_quantity is 999.999E24" do
          let(:decimal_quantity) { 999.999e+24.to_d }
          it { expect(subject).to eq 24.0 }
        end
        context "decimal_quantity is 1.0E27" do
          let(:decimal_quantity) { 1.0e+27.to_d }
          it { expect(subject).to eq 24.0 }
        end
      end
      context "below min" do
        context "decimal_quantity is 1.0E-24" do
          let(:decimal_quantity) { 1.0e-24.to_d }
          it { expect(subject).to eq -24.0 }
        end
        context "decimal_quantity is 999.999E-27" do
          let(:decimal_quantity) { 999.999e-27.to_d }
          it { expect(subject).to eq -24.0 }
        end
        context "decimal_quantity is 1.0E-27" do
          let(:decimal_quantity) { 1.0e-27.to_d }
          it { expect(subject).to eq -24.0 }
        end
      end
    end

    describe "decimal_quantity" do
      let(:quantity) { 100.0 }
      let(:quantity_unit) { "kg" }
      subject { Quantity.decimal_quantity(quantity, quantity_unit) }
      it { expect(subject.class).to eq(BigDecimal) }
      it { expect(subject).to eq(100000) }
    end

    describe "string_quantity" do
      let(:quantity) { 100.0 }
      let(:quantity_unit) { "kg" }
      subject { Quantity.string_quantity(quantity, quantity_unit) }
      it { expect(subject).to eq("100.0 kg") }
    end

    describe "unit_exists?" do
      subject { Quantity.unit_exists?(quantity_unit) }
      context "exists" do
        let(:quantity_unit) { "kg" }
        it { expect(subject).to eq(true) }
      end
      context "not exists" do
        context "error unit" do
          let(:quantity_unit) { "kglam" }
          it { expect(subject).to eq(false) }
        end
        context "other unit" do
          let(:quantity_unit) { "km" }
          it { expect(subject).to eq(false) }
        end
      end
    end
  end
end
