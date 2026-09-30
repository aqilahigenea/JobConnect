import '../models/job_model.dart';

List<JobModel> dummyJobs = [
  JobModel(
    id: '1',
    title: 'Flutter Developer',
    company: 'PT Tech Innovation',
    location: 'Jakarta (Remote)',
    salary: 'Rp 8.000.000 - Rp 12.000.000',
    description: 'Bertanggung jawab mengembangkan aplikasi mobile berbasis Flutter dan integrasi API.',
    category: 'IT & Software',
  ),
  JobModel(
    id: '2',
    title: 'UI/UX Designer',
    company: 'Creative Studio',
    location: 'Bandung',
    salary: 'Rp 6.000.000 - Rp 9.000.000',
    description: 'Merancang wireframe, prototype, dan user interface untuk aplikasi web dan mobile.',
    category: 'Design',
  ),
  JobModel(
    id: '3',
    title: 'Data Analyst',
    company: 'Data Jaya Corp',
    location: 'Surabaya',
    salary: 'Rp 7.000.000 - Rp 10.000.000',
    description: 'Menganalisis data bisnis dan menyajikan laporan visualisasi data menggunakan Python/SQL.',
    category: 'Data Science',
  ),
];