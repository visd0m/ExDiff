defmodule ExDiff do
  @moduledoc """
  Documentation for ExDiff.
  """

  @type t :: %{
               (String.t() |
                atom()) => diff()
             }

  @type diff :: %{
                  removed: [String.t() | atom()],
                  added: [String.t() | atom()],
                  changed: %{
                    (String.t() |
                     atom()) => %{
                      old_value: String.t(),
                      new_value: String.t()
                    }
                  }
                }

  @spec diff((String.t() | atom()), any, any) :: {:ok, ExDiff.t()} | {:error, String.t()}
  def diff(key \\ "root", stuff1, stuff2)

  def diff(key, %{} = map_1, %{} = map_2) do
    diff = Enum.concat(
             Map.keys(map_1),
             Map.keys(map_2)
           )
           |> Enum.uniq
           |> Enum.reduce(
                nil,
                fn key, acc ->
                  new_diff = diff(key, Map.get(map_1, key), Map.get(map_2, key))
                  merge_diffs(acc, new_diff)
                end
              )

    if diff == nil,
       do: nil,
       else: %{
         key => diff
       }
  end

  def diff(k, %{__struct__: _} = struct_1, %{__struct__: _} = struct_2) do
    diff(k, Map.from_struct(struct_1), Map.from_struct(struct_2))
  end

  def diff(k, [_ | _] = list_1, [_ | _] = list_2)  do
    indexes = 0..max(Enum.count(list_1), Enum.count(list_2))
    diff = Enum.reduce(
      indexes,
      nil,
      fn index, acc ->
        new_diff = diff("#{index}", Enum.at(list_1, index, nil), Enum.at(list_2, index, nil))
        merge_diffs(acc, new_diff)
      end
    )

    if diff == nil,
       do: nil,
       else: %{
         k => diff
       }
  end

  def diff(k, v1, v2) do
    cond do
      v1 == v2 -> nil
      v1 == nil -> %{added: [k]}
      v2 == nil -> %{removed: [k]}
      v1 != v2 ->
        s1 = Poison.encode!(v1)
        s2 = Poison.encode!(v2)
        %{
          changed: %{
            k => %{
              old_value: s1,
              new_value: s2
            }
          }
        }
    end
  end

  defp merge_diffs(old_diff, new_diff) do
    cond do
      new_diff == nil && old_diff == nil -> nil
      new_diff == nil -> old_diff
      old_diff == nil -> new_diff
      true -> Map.merge(
                old_diff,
                new_diff,
                fn
                  _k, [_ | _] = v1, [_ | _] = v2 ->
                    v1 ++ v2

                  :changed, %{} = v1, %{} = v2 ->
                    Map.merge(v1, v2)
                end
              )
    end
  end

  def test do
    map_1 = Poison.decode!(
      ~s({"data":{"quoteFormConfiguration":{"quoteAniaData":null,"quoteUserData":{"atr":{"details":[{"equal":"0","equalMixed":null,"equalObjects":null,"equalPeople":null,"main":"0","mainMixed":null,"mainObjects":null,"mainPeople":null,"year":2013},{"equal":"0","equalMixed":null,"equalObjects":null,"equalPeople":null,"main":"0","mainMixed":null,"mainObjects":null,"mainPeople":null,"year":2014},{"equal":null,"equalMixed":"0","equalObjects":"0","equalPeople":"0","main":null,"mainMixed":"0","mainObjects":"0","mainPeople":"0","year":2015},{"equal":null,"equalMixed":"0","equalObjects":"0","equalPeople":"0","main":null,"mainMixed":"0","mainObjects":"0","mainPeople":"0","year":2016},{"equal":null,"equalMixed":"0","equalObjects":"0","equalPeople":"0","main":null,"mainMixed":"0","mainObjects":"0","mainPeople":"0","year":2017},{"equal":null,"equalMixed":"0","equalObjects":"0","equalPeople":"0","main":null,"mainMixed":"0","mainObjects":"0","mainPeople":"0","year":2018},{"equal":null,"equalMixed":"0","equalObjects":"0","equalPeople":"0","main":null,"mainMixed":"0","mainObjects":"0","mainPeople":"0","year":2019}],"hasIur":false,"iur":null,"toInternalRiskCategory":null,"toRiskCategory":null},"contractor":null,"contractorIsOwner":true,"conventionDiscountCode":null,"driver":null,"effectiveDateDate":null,"effectiveDateTime":null,"email":null,"guideType":null,"inheritedAtr":{"details":[],"hasIur":null,"iur":null,"toInternalRiskCategory":null,"toRiskCategory":null},"inheritedAtrType":"N","inheritedOwner":{"birthCity":null,"birthCountry":"ITA","birthDate":null,"bornAbroad":false,"civilStatus":null,"companyName":null,"companyType":null,"domiciliaryAddress":null,"domiciliaryCap":null,"domiciliaryCity":null,"domiciliaryCivicNumber":null,"firstName":null,"fiscalCode":null,"gender":null,"lastName":null,"licenseYear":null,"noLicense":false,"occupation":null,"residenceIsDomicile":true,"residentialAddress":null,"residentialCap":null,"residentialCity":null,"residentialCivicNumber":null,"vat":null},"inheritedVehicle":{"activity":null,"brandCode":null,"displacement":null,"finitureCode":null,"hasLoan":false,"kw":null,"loanCompany":null,"loanExpirationDate":null,"loanType":null,"modelCode":null,"ownUse":true,"plateNumber":null,"powerSource":null,"purchaseDate":null,"registrationDate":null,"type":null,"value":null,"yearMileage":null},"insuranceType":"B","issuingCompany":null,"legalEntity":false,"originalSaveId":null,"owner":{"birthCity":null,"birthCountry":"ITA","birthDate":"1988-01-31","bornAbroad":false,"civilStatus":null,"companyName":null,"companyType":null,"domiciliaryAddress":null,"domiciliaryCap":null,"domiciliaryCity":null,"domiciliaryCivicNumber":null,"firstName":null,"fiscalCode":null,"gender":null,"lastName":null,"licenseYear":null,"noLicense":false,"occupation":null,"residenceIsDomicile":true,"residentialAddress":null,"residentialCap":null,"residentialCity":null,"residentialCivicNumber":null,"vat":null},"phoneNumber":null,"privacyAll":null,"source":null,"userPrivacyAll":null,"userPrivacyCommercial":null,"userPrivacyMarketing":null,"userPrivacyThirdPart":null,"vehicle":{"activity":null,"brandCode":null,"displacement":null,"finitureCode":null,"hasLoan":false,"kw":null,"loanCompany":null,"loanExpirationDate":null,"loanType":null,"modelCode":null,"ownUse":true,"plateNumber":"DR17027","powerSource":null,"purchaseDate":null,"registrationDate":null,"type":"motorcycle","value":null,"yearMileage":null},"whoIsDriver":"owner"},"useFastquote":true,"vehicleInfo":{"availableFinitures":[{"brandCode":"000015","brandName":"Yamaha","code":"00420801","displacement":249,"fuelFlag":"P","kw":15,"mass":18400,"modelCode":"000956","name":"ABS","value":0},{"brandCode":"000015","brandName":"Yamaha","code":"00420901","displacement":249,"fuelFlag":"P","kw":15,"mass":18000,"modelCode":"000956","name":"Sport","value":0}],"vehicleType":"motorcycle","weight":355}}}})
    )

    map_2 = Poison.decode!(
      ~s({"data":{"quoteFormConfiguration":{"quoteAniaData":null,"quoteUserData":{"atr":{"details":[{"equal":"0","equalMixed":null,"equalObjects":null,"equalPeople":null,"main":"0","mainMixed":null,"mainObjects":null,"mainPeople":null,"year":2013},{"equal":"0","equalMixed":null,"equalObjects":null,"equalPeople":null,"main":"0","mainMixed":null,"mainObjects":null,"mainPeople":null,"year":2014},{"equal":null,"equalMixed":"0","equalObjects":"0","equalPeople":"0","main":null,"mainMixed":"0","mainObjects":"0","mainPeople":"0","year":2015},{"equal":null,"equalMixed":"0","equalObjects":"0","equalPeople":"0","main":null,"mainMixed":"0","mainObjects":"0","mainPeople":"0","year":2016},{"equal":null,"equalMixed":"0","equalObjects":"0","equalPeople":"0","main":null,"mainMixed":"0","mainObjects":"0","mainPeople":"0","year":2017},{"equal":null,"equalMixed":"0","equalObjects":"0","equalPeople":"0","main":null,"mainMixed":"0","mainObjects":"0","mainPeople":"0","year":2018},{"equal":null,"equalMixed":"0","equalObjects":"0","equalPeople":"0","main":null,"mainMixed":"0","mainObjects":"0","mainPeople":"0","year":2019}],"hasIur":false,"iur":null,"toInternalRiskCategory":null,"toRiskCategory":null},"contractor":null,"contractorIsOwner":true,"conventionDiscountCode":null,"driver":null,"effectiveDateDate":null,"effectiveDateTime":null,"email":null,"guideType":null,"inheritedAtr":{"details":[],"hasIur":false,"iur":null,"toInternalRiskCategory":null,"toRiskCategory":null},"inheritedAtrType":"N","inheritedOwner":{"birthCity":null,"birthCountry":"ITA","birthDate":null,"bornAbroad":false,"civilStatus":null,"companyName":null,"companyType":null,"domiciliaryAddress":null,"domiciliaryCap":null,"domiciliaryCity":null,"domiciliaryCivicNumber":null,"firstName":null,"fiscalCode":null,"gender":null,"lastName":null,"licenseYear":null,"noLicense":false,"occupation":null,"residenceIsDomicile":true,"residentialAddress":null,"residentialCap":null,"residentialCity":null,"residentialCivicNumber":null,"vat":null},"inheritedVehicle":{"activity":null,"brandCode":null,"displacement":null,"finitureCode":null,"hasLoan":false,"kw":null,"loanCompany":null,"loanExpirationDate":null,"loanType":null,"modelCode":null,"ownUse":true,"plateNumber":null,"powerSource":null,"purchaseDate":null,"registrationDate":null,"type":null,"value":null,"yearMileage":null},"insuranceType":"B","issuingCompany":null,"legalEntity":false,"originalSaveId":null,"owner":{"birthCity":null,"birthCountry":"ITA","birthDate":"1957-05-09","bornAbroad":false,"civilStatus":null,"companyName":null,"companyType":null,"domiciliaryAddress":null,"domiciliaryCap":null,"domiciliaryCity":null,"domiciliaryCivicNumber":null,"firstName":null,"fiscalCode":null,"gender":null,"lastName":null,"licenseYear":null,"noLicense":false,"occupation":null,"residenceIsDomicile":true,"residentialAddress":null,"residentialCap":null,"residentialCity":null,"residentialCivicNumber":null,"vat":null},"phoneNumber":null,"privacyAll":null,"source":null,"userPrivacyAll":null,"userPrivacyCommercial":null,"userPrivacyMarketing":null,"userPrivacyThirdPart":null,"vehicle":{"activity":null,"brandCode":null,"displacement":null,"finitureCode":null,"hasLoan":false,"kw":null,"loanCompany":null,"loanExpirationDate":null,"loanType":null,"modelCode":null,"ownUse":true,"plateNumber":"BS184EV","powerSource":null,"purchaseDate":null,"registrationDate":null,"type":"car","value":null,"yearMileage":null},"whoIsDriver":"owner"},"useFastquote":true,"vehicleInfo":{"availableFinitures":[{"brandCode":"000149","brandName":"NISSAN","code":"048202199908","displacement":2664,"fuelFlag":"D","kw":92,"mass":1830,"modelCode":"002390","name":"Terrano II 2.7 Tdi 3 porte Elegance","value":0},{"brandCode":"000149","brandName":"NISSAN","code":"048204199908","displacement":2664,"fuelFlag":"D","kw":92,"mass":1830,"modelCode":"002390","name":"Terrano II 2.7 Tdi 3 porte Luxury","value":0},{"brandCode":"000149","brandName":"NISSAN","code":"048203200009","displacement":2664,"fuelFlag":"D","kw":92,"mass":1830,"modelCode":"002390","name":"Terrano II 2.7 Tdi 3 porte Sport Safari","value":0},{"brandCode":"000149","brandName":"NISSAN","code":"049733200012","displacement":2664,"fuelFlag":"D","kw":92,"mass":1830,"modelCode":"002390","name":"Terrano II 2.7 Tdi 3 porte Anniversary","value":0}],"vehicleType":"car","weight":2510}}}})
    )
    diff(
      map_1,
      map_2
    )
  end
end
