//
//  BaseTableController.swift
//  BaseProject
//
//  Created by Minh Tien on 6/2/16.
//  Copyright © 2016 MTLAB. All rights reserved.
//

import UIKit

class BaseTableController: NSObject {
    weak private var _targetTableView: UITableView?
    private var items = [AnyObject]() {
        didSet {
            _targetTableView?.reloadData()
        }
    }
    
    private var sections = [AnyObject]()

    convenience init(initWithTargetTable targetTableView:UITableView) {
        self.init()
        self.initWithTargetTableView(targetTableView)
        fetchData()
    }
    
    func fetchData() {}
    
    private func initWithTargetTableView(_ targetTableView:UITableView) {
        _targetTableView = targetTableView
        _targetTableView?.delegate = self
        _targetTableView?.dataSource = self
        self.registerNibWithTargetTableView(targetTableView)
    }
    
    func registerNibWithTargetTableView(_ targetTableView: UITableView) {
        assert(false, "This is abstract method, you must implement it in subclass")
    }
    
    func getCellIdentify(withItem item: AnyObject?, returnClassName: Bool) -> String {
        assert(false, "This is abstact method, you must implement it in subclass")
        return ""
    }
    
    func getHeaderIdentifiWithItem(_ item: AnyObject, returnClassName: Bool) -> String {
        assert(false, "This is abstract method, you must implement it in subclass")
        return ""
    }
    
    func itemAtIndexPath(_ indexPath: IndexPath) -> AnyObject? {
        guard indexPath.section < items.count else { return nil }
        guard let listItemAtSection = items[indexPath.section] as? [AnyObject] else { return nil }
        guard listItemAtSection.count > indexPath.row else { return nil }
        
        return listItemAtSection[indexPath.row] as AnyObject
    }
    
    func listItemOfSection(_ section: Int) -> AnyObject? {
        return section < items.count ? items[section] : nil
    }
    
    func updateWithListItem(_ listItems:Array<AnyObject>) {
        items = listItems
    }
    
    func updateWithListItem(_ listItem: Array<AnyObject>, listSections: Array<AnyObject>) {
        sections = listSections
        items = listItem
    }
    
    func reloadData() {
        _targetTableView?.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension BaseTableController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cell =  NSClassFromString(self.getCellIdentify(withItem: self.itemAtIndexPath(indexPath), returnClassName: true)) as? BaseTableViewCell.Type else {
            return UITableViewAutomaticDimension
        }
        return cell.height(withItem: self.itemAtIndexPath(indexPath))
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard sections.count > section else {
            return 0.0
        }
        
        let item = sections[section]
        let headerClassName = self.getHeaderIdentifiWithItem(item, returnClassName: true)
        let  header = NSClassFromString(headerClassName) as! BaseHeaderTableView.Type;
        
        return header.heightWithItem(item)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard sections.count > section else {
            return nil
        }
        
        let item = sections[section]
        let headerIdentifier = self.getHeaderIdentifiWithItem(item, returnClassName: false)
        
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifier) as? BaseHeaderTableView  else {
            return nil
        }
        headerView.configHeaderWithData(item)
        
        return headerView
    }
}

extension BaseTableController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.itemAtIndexPath(indexPath)
        let cellIdentify = self.getCellIdentify(withItem: item, returnClassName: false)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentify, for: indexPath)
        
        if let baseCell = cell as? BaseTableViewCell {
            baseCell.configCellWithData(item)
            baseCell.indexPath = indexPath
        }
        
        return cell
    }
}

extension UITableView {
    func register<T>(cellType: T.Type) where T: BaseTableViewCell {
        register(T.nib(), forCellReuseIdentifier: T.nibName())
    }
    
    func register<T>(headerType: T.Type) where T: BaseHeaderTableView {
        register(T.nib(), forHeaderFooterViewReuseIdentifier: T.nibName())
    }
    
    func register<T>(footerType: T.Type) where T: BaseHeaderTableView {
        register(T.nib(), forHeaderFooterViewReuseIdentifier: T.nibName())
    }
}
