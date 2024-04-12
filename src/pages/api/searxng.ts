import {NextApiRequest, NextApiResponse} from 'next';
import axios from 'axios';

// 从环境变量中获取预设的 token
const presetToken = process.env.PRESET_TOKEN;

interface Result {
    title: string;
    link: string;
    content: string;
}

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
    // 获取 Authorization 头部
    const authHeader = req.headers.authorization;
    // 检查 Authorization 头部是否存在
    if (!authHeader) {
        res.status(401).json({message: 'Authorization header is required.'});
        return;
    }
    // 检查 Authorization 头部的值是否与预设的 token 匹配
    if (authHeader !== `Bearer ${presetToken}`) {
        res.status(401).json({message: 'Invalid token.'});
        return;
    }
    // 处理POST请求
    if (req.method === 'POST') {
        let body = req.body
        const {query} = body;
        if (!query) {
            res.status(400).json({message: 'query is required in the request body.'});
            return;
        }
        const response = await fetchSearXng(query);
        if (response) {
            // 获取最前面的5条数据
            const results = response.slice(0, 5);
            res.status(200).json({results});
        } else {
            res.status(500).json({message: 'Failed to fetch and parse the article.'});
        }
    } else {
        // 处理其他类型的请求，如GET，PUT等
        res.setHeader('Allow', ['POST']);
        res.status(405).end(`Method ${req.method} Not Allowed`);
    }
}


async function fetchSearXng(query: string): Promise<Result[]> {
    try {
        const url = `https://www.composere.com/search?q=${query}&format=json`
        console.log(url)
        const response = await axios.get(url) // Set timeout to 5000 milliseconds
        if (response.data && response.data.results) {
            return response.data.results.map((result: any) => ({
                title: result.title,
                link: result.url,
                content: result.content
            }));
        }
        return [];
    } catch (error) {
        console.error(error);
        return [];
    }
}