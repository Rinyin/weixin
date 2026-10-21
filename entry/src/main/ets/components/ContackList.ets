import { PageHeader } from './PageHeader';
import { AppStore } from '../services/AppStore';
import { Contact } from '../model/Models';
import { avatarResource, BACKGROUND, GREEN, TEXT_SECONDARY } from '../common/Theme';

interface ContactGroup {
  initial: string;
  contacts: Contact[];
}

@Component
export struct ContackList {
  @StorageLink('fontScale') fontScale: number = 1;
  @StorageLink('revision') @Watch('refresh') revision: number = 0;
  @State query: string = '';
  @State groups: ContactGroup[] = [];
  @State initials: string[] = [];
  @State selectedIndex: number = 0;
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void { this.refresh(); }

  refresh(): void {
    const query = this.query.trim().toLowerCase();
    const contacts = AppStore.data.contacts.filter((item: Contact) =>
      item.name.toLowerCase().includes(query) || item.account.toLowerCase().includes(query));
    const groups: ContactGroup[] = [];
    contacts.sort((a: Contact, b: Contact) => a.initial.localeCompare(b.initial) || a.name.localeCompare(b.name))
      .forEach((contact: Contact) => {
        let group = groups.find((item: ContactGroup) => item.initial === contact.initial);
        if (!group) { group = { initial: contact.initial, contacts: [] }; groups.push(group); }
        group.contacts.push(contact);
      });
    this.groups = groups;
    this.initials = groups.map((group: ContactGroup) => group.initial);
    this.selectedIndex = 0;
  }

  @Builder
  groupHeader(initial: string) {
    Text(initial).fontSize(13 * this.fontScale).fontColor(TEXT_SECONDARY)
      .padding({ left: 16, top: 6, bottom: 6 }).width('100%').backgroundColor(BACKGROUND)
  }

  build() {
    Column() {
      PageHeader({ title: '通讯录', back: false, action: '⊕', actionLabel: '添加朋友', onAction: () => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/AddFriend' });
      } })
      Search({ value: this.query, placeholder: '搜索' })
        .textFont({ size: 16 * this.fontScale }).placeholderFont({ size: 16 * this.fontScale })
        .height(36 * this.fontScale).backgroundColor(Color.White).borderRadius(6).searchIcon({ size: 16, color: '#B2B2B2' })
        .placeholderColor('#B2B2B2').margin({ left: 8, right: 8, bottom: 8 })
        .onChange((value: string) => { this.query = value; this.refresh(); })
      Stack({ alignContent: Alignment.End }) {
        List({ scroller: this.scroller }) {
          ListItem() {
            Row({ space: 14 }) {
              Image($r('app.media.newFriends')).width(40).height(40).padding(8)
                .fillColor(Color.White).backgroundColor('#FA9D3B').borderRadius(6)
              Text('新的朋友').fontSize(17 * this.fontScale).layoutWeight(1)
            }.padding({ left: 16, right: 16, top: 10, bottom: 10 }).width('100%').backgroundColor(Color.White)
          }.onClick(() => this.getUIContext().getRouter().pushUrl({ url: 'pages/AddFriend' }))
          ForEach(this.groups, (group: ContactGroup) => {
            ListItemGroup({ header: this.groupHeader(group.initial) }) {
              ForEach(group.contacts, (contact: Contact) => {
                ListItem() {
                  Row({ space: 14 }) {
                    Image(avatarResource(contact.avatar)).width(40).height(40).borderRadius(6)
                    Text(contact.name).fontSize(17 * this.fontScale).layoutWeight(1)
                      .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                  }.padding({ left: 16, top: 10, bottom: 10, right: 35 }).width('100%').backgroundColor(Color.White)
                }.onClick(() => this.getUIContext().getRouter().pushUrl({
                  url: 'pages/ContactDetail', params: { contactId: contact.id }
                }))
              }, (contact: Contact) => contact.id)
            }.divider({ strokeWidth: 0.5, color: '#E5E5E5', startMargin: 70 })
          }, (group: ContactGroup) => group.initial + group.contacts.map((contact: Contact) => contact.id).join('|'))
          ListItem() {
            Text(this.groups.length === 0 ? '没有找到联系人' : AppStore.data.contacts.length.toString() + ' 位朋友')
              .fontSize(14 * this.fontScale).fontColor(TEXT_SECONDARY).textAlign(TextAlign.Center).padding(24).width('100%')
          }
        }.width('100%').height('100%').scrollBar(BarState.Off)
          .onScrollIndex((first: number) => { this.selectedIndex = Math.max(0, Math.min(this.initials.length - 1, first - 1)); })
        if (this.initials.length > 1) {
          AlphabetIndexer({ arrayValue: this.initials, selected: this.selectedIndex })
            .font({ size: 13 * this.fontScale }).selectedFont({ size: 13 * this.fontScale })
            .popupFont({ size: 22 * this.fontScale }).popupItemFont({ size: 16 * this.fontScale })
            .selectedColor(Color.White).selectedBackgroundColor(GREEN).color('#555555')
            .itemSize(23 * this.fontScale).margin({ right: 3 }).onSelect((index: number) => {
              this.selectedIndex = index;
              this.scroller.scrollToIndex(index + 1, true, ScrollAlign.START);
            })
        }
      }.layoutWeight(1).width('100%')
    }.width('100%').height('100%').backgroundColor(BACKGROUND)
  }
}
