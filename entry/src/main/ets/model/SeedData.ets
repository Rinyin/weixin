import { AppData, Contact, ChatMessage, Moment } from './Models';

export function seedMoments(): Moment[] {
  const now = Date.now();
  return [
    { id: 'moment-cats', authorId: 'aobing', text: '把今天的好心情分享给你。☀️', image: 'img1',
      createdAt: now - 3600000, liked: false, comments: [] },
    { id: 'moment-day', authorId: 'huzi', text: '忙完功课，也别忘记出去走走。', image: 'cherry',
      createdAt: now - 7200000, liked: false, comments: [] }
  ];
}

export function seedData(): AppData {
  const contacts: Contact[] = [
    { id: 'aobing', name: '敖丙', account: 'aobing', avatar: 'avatar2', region: '东海 · 龙宫', signature: '山海相逢，来日可期。', initial: 'A' },
    { id: 'bingjia', name: '兵甲', account: 'bingjia', avatar: 'avatar6', region: '陈塘关', signature: '今天也要认真值守。', initial: 'B' },
    { id: 'huzi', name: '虎子', account: 'huzi', avatar: 'avatar1', region: '陈塘关', signature: '一起去踢毽子吧！', initial: 'H' },
    { id: 'jiejieshou', name: '结界兽', account: 'jiejieshou', avatar: 'avatar5', region: '山河社稷图', signature: '偷得浮生半日闲。', initial: 'J' },
    { id: 'lijing', name: '李靖', account: 'lijing', avatar: 'avatar6', region: '陈塘关', signature: '守护一方平安。', initial: 'L' },
    { id: 'nezha', name: '哪吒', account: 'nezha', avatar: 'avatar3', region: '陈塘关', signature: '我命由我。', initial: 'N' },
    { id: 'taiyi', name: '太乙真人', account: 'taiyi', avatar: 'avatar4', region: '乾元山', signature: '慢慢来，也是一种修行。', initial: 'T' }
  ];
  const now = Date.now();
  const messages: ChatMessage[] = [
    { id: 'seed-1', contactId: 'huzi', text: '今天风很好，一起去海边踢毽子吧！', mine: false, createdAt: now - 120000 },
    { id: 'seed-2', contactId: 'aobing', text: '海边见，给你带了新的毽子。', mine: false, createdAt: now - 1800000 },
    { id: 'seed-3', contactId: 'nezha', text: '等你一起出发。', mine: false, createdAt: now - 3600000 },
    { id: 'seed-4', contactId: 'taiyi', text: '修行之余，也要好好吃饭。', mine: false, createdAt: now - 7200000 }
  ];
  return {
    version: 2,
    contacts: contacts,
    messages: messages,
    moments: seedMoments(),
    profile: { name: '小林', account: 'harmony_student', avatar: 'avatar7', region: '中国', signature: '记录生活里的小美好。' }
  };
}
