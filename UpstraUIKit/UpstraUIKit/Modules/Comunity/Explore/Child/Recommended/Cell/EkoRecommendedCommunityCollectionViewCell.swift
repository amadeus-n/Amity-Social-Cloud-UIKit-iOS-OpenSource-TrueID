//
//  EkoRecommendedCommunityCollectionViewCell.swift
//  UpstraUIKit
//
//  Created by Sarawoot Khunsri on 6/10/2563 BE.
//  Copyright © 2563 Upstra. All rights reserved.
//

import UIKit

final class EkoRecommendedCommunityCollectionViewCell: UICollectionViewCell, Nibbable {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var avatarView: EkoAvatarView!
    @IBOutlet private var displayNameLabel: UILabel!
    @IBOutlet private var categoryLabel: UILabel!
    @IBOutlet private var memberLabel: UILabel!
    @IBOutlet private var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.image = nil
        displayNameLabel.text = nil
        categoryLabel.text = nil
        memberLabel.text = nil
        descLabel.text = nil
    }
    
    func display(with model: EkoCommunityModel) {
        avatarView.setImage(withImageId: model.avatarId, placeholder: EkoIconSet.defaultCommunity)
        displayNameLabel.text = model.displayName
        categoryLabel.text = model.category
        memberLabel.text = String.localizedStringWithFormat(EkoLocalizedStringSet.members, "\(model.membersCount)")
        descLabel.text = model.description == "" ? "-":model.description
    }

}

// MARK: - Setup view
private extension EkoRecommendedCommunityCollectionViewCell {
    func setupView() {
        setupContainerView()
        setupAvatarView()
        setupDisplayName()
        setupCategory()
        setupMember()
        setupDesc()
    }
    
    func setupContainerView() {
        containerView.layer.cornerRadius = 4
    }
    
    func setupAvatarView() {
        avatarView.placeholder = EkoIconSet.defaultCommunity
        avatarView.backgroundColor = EkoColorSet.base.blend(.shade3)
    }
    
    func setupDisplayName() {
        displayNameLabel.text = ""
        displayNameLabel.textColor = EkoColorSet.base
        displayNameLabel.font = EkoFontSet.bodyBold
    }
    
    func setupCategory() {
        categoryLabel.text = ""
        categoryLabel.textColor = EkoColorSet.base.blend(.shade1)
        categoryLabel.font = EkoFontSet.caption
    }
    
    func setupMember() {
        memberLabel.text = ""
        memberLabel.textColor = EkoColorSet.base.blend(.shade1)
        memberLabel.font = EkoFontSet.caption
    }
    
    func setupDesc() {
        descLabel.text = ""
        descLabel.textColor = EkoColorSet.base
        descLabel.font = EkoFontSet.caption
        descLabel.numberOfLines = 3
    }
}