Assets {
  Id: 4883619684210515678
  Name: "Backpack"
  PlatformAssetType: 5
  TemplateAsset {
    ObjectBlock {
      RootId: 13019994109890294979
      Objects {
        Id: 13019994109890294979
        Name: "Backpack"
        Transform {
          Scale {
            X: 1
            Y: 1
            Z: 1
          }
        }
        ParentId: 4781671109827199097
        UnregisteredParameters {
          Overrides {
            Name: "cs:Equipment"
            String: "0/0/0/0/0/0/0/"
          }
          Overrides {
            Name: "cs:Equipment:tooltip"
            String: "String of currently Equipped items"
          }
          Overrides {
            Name: "cs:Equipment:isrep"
            Bool: true
          }
        }
        WantsNetworking: true
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CameraCollidable {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        EditorIndicatorVisibility {
          Value: "mc:eindicatorvisibility:visiblewhenselected"
        }
        Inventory {
          InventoryNumSlots: 37
          PickupItemsOnStart: true
        }
        NetworkRelevanceDistance {
          Value: "mc:eproxyrelevance:critical"
        }
        IsReplicationEnabledByDefault: true
      }
    }
    PrimaryAssetId {
      AssetType: "None"
      AssetId: "None"
    }
  }
  SerializationVersion: 118
}
